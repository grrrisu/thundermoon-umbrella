defmodule Sim.AccessProxy do
  use GenServer

  @doc """
  Keeps updates on an agent in sequence to avoid race conditions by overwriting data,
  while remaining responsive to just read operations.

  AccessProxy.exclusive_get() # blocks until an other exclusive client updates the data
  AccessProxy.get() # never blocks
  AccessProxy.update(data) # releases the lock and will reply to the next client in line with the updated data

  Example:
  {:ok, pid} = Agent.start_link(fn -> 42 end)

  # normaly the agent will be referenced by name not pid, so that we don't need to monitor the agent
  {:ok, _} = Sim.AccessProxy.start_link(agent: pid)

  1..3
  |> Enum.map(fn _n ->
      Task.async(fn ->
        value = Sim.AccessProxy.exclusive_get()
        Process.sleep(1_000)
        :ok = Sim.AccessProxy.update(value + 1)
      end)
    end)
  |> Task.await_many()
  45 = Sim.AccessProxy.get()
  """

  # milliseconds
  @max_duration 5_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, Keyword.delete(opts, :name), name: opts[:name] || __MODULE__)
  end

  def get(server \\ __MODULE__, func \\ & &1) do
    GenServer.call(server, {:get, func})
  end

  def exclusive_get(server \\ __MODULE__, func \\ & &1) do
    GenServer.call(server, {:exclusive_get, func})
  end

  def update(server \\ __MODULE__, data)

  def update(server, func) when is_function(func) do
    GenServer.call(server, {:update, func})
  end

  def update(server, data) do
    GenServer.call(server, {:update, fn _ -> data end})
  end

  def init(opts) do
    {:ok,
     %{
       caller: nil,
       agent: opts[:agent],
       requests: [],
       max_duration: opts[:max_duration] || @max_duration
     }}
  end

  def handle_call({:get, func}, _from, state) do
    {:reply, get_data(state.agent, func), state}
  end

  def handle_call({:exclusive_get, func}, {pid, _} = from, %{caller: nil} = state) do
    monitor_ref = Process.monitor(pid)
    start_check_timeout(from, monitor_ref, state.max_duration)
    {:reply, get_data(state.agent, func), %{state | caller: {pid, monitor_ref}}}
  end

  def handle_call({:exclusive_get, func}, {pid, _}, %{caller: {pid, _}} = state) do
    {:reply, get_data(state.agent, func), state}
  end

  def handle_call({:exclusive_get, func}, {pid, _} = from, %{caller: caller} = state) do
    monitor_ref = Process.monitor(pid)
    {:noreply, %{state | requests: state.requests ++ [{from, monitor_ref, func}]}}
  end

  def handle_call({:update, func}, {pid, _}, %{caller: {pid, monitor_ref}, requests: []} = state) do
    update_data(state.agent, func)
    Process.demonitor(monitor_ref, [:flush])
    {:reply, :ok, %{state | caller: nil}}
  end

  def handle_call({:update, func}, {pid, _}, %{caller: {pid, monitor_ref}} = state) do
    update_data(state.agent, func)
    Process.demonitor(monitor_ref, [:flush])
    {next_caller, state} = reply_to_next_caller(state)
    {:reply, :ok, %{state | caller: next_caller}}
  end

  def handle_call({:update, _func}, _from, state) do
    {:reply,
     {:error,
      "request the data first with AccessProxy#exclusive_get or maybe too much time elapsed since exclusive_get was called"},
     state}
  end

  def handle_info(
        {:check_timeout, {pid, _ref}, monitor_ref},
        %{caller: {pid, monitor_ref}, requests: []} = state
      ) do
    Process.demonitor(monitor_ref, [:flush])
    {:noreply, %{state | caller: nil}}
  end

  def handle_info(
        {:check_timeout, {pid, _ref}, monitor_ref},
        %{caller: {pid, monitor_ref}} = state
      ) do
    Process.demonitor(monitor_ref, [:flush])
    {next_caller, state} = reply_to_next_caller(state)
    {:noreply, %{state | caller: next_caller}}
  end

  def handle_info({:check_timeout, _}, state) do
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, %{caller: nil} = state) do
    {:noreply, state}
  end

  def handle_info(
        {:DOWN, _ref, :process, pid, _reason},
        %{caller: {pid, _}, requests: []} = state
      ) do
    {:noreply, %{state | caller: nil}}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, %{caller: {pid, _}} = state) do
    {next_caller, state} = reply_to_next_caller(state)
    {:noreply, %{state | caller: next_caller}}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    requests = Enum.reject(state.requests, fn {req_pid, _ref, _func} -> pid == req_pid end)
    {:noreply, %{state | requests: requests}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp get_data(agent, func) do
    Agent.get(agent, func)
  end

  defp update_data(agent, func) do
    :ok = Agent.update(agent, func)
  end

  defp reply_to_next_caller(state) do
    [{{pid, _ref} = next_caller, monitor_ref, get_func} | requests] = state.requests
    :ok = GenServer.reply(next_caller, get_data(state.agent, get_func))
    start_check_timeout(next_caller, monitor_ref, state.max_duration)
    {{pid, monitor_ref}, %{state | requests: requests}}
  end

  defp start_check_timeout(current_caller, monitor_ref, max_duration) do
    Process.send_after(self(), {:check_timeout, current_caller, monitor_ref}, max_duration)
  end
end
