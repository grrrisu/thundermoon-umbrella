defmodule Sim.Realm.CommandGuard do
  use GenServer

  require Logger

  def start_link(commands_module) do
    GenServer.start_link(__MODULE__, commands_module, name: __MODULE__)
  end

  def init(commands_module) do
    {:ok,
     %{
       commands_module: commands_module,
       pending_commands: :queue.new(),
       current_lock: nil,
       task: {nil, nil}
     }}
  end

  # --- client ---

  def receive(command) do
    GenServer.call(__MODULE__, {:receive, command})
  end

  # --- server ---

  def handle_call({:receive, command}, _from, state) do
    {:reply, :ok,
     state
     |> add_command(command)
     |> next_command()}
  end

  # The task completed successfully
  def handle_info({ref, answer}, %{task: {ref, command}} = state) do
    # We don't care about the DOWN message now, so let's demonitor and flush it
    Process.demonitor(ref, [:flush])
    Logger.info("task executing command #{command} finished with result #{answer}")
    {:noreply, finish_command(state, command)}
  end

  # The task failed
  def handle_info({:DOWN, ref, :process, _pid, reason}, %{task: {ref, command}} = state) do
    Logger.warn("task executing command #{command} failed with reason #{reason}")
    {:noreply, finish_command(state, command)}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp add_command(state, command) do
    %{state | pending_commands: :queue.in(command, state.pending_commands)}
  end

  defp next_command(state) do
    with {command, queue} when command != :empty <- :queue.out(state.pending_commands),
         {:ok, new_lock} <- state.commands_module.lock(state, command) do
      task = execute_command(state, command)
      %{state | pending_commands: queue, current_lock: new_lock, task: {task.ref, command}}
    else
      {:empty, _queue} -> %{state | task: {nil, nil}}
      {:locked, _current_lock} -> %{state | task: {nil, nil}}
    end
  end

  defp execute_command(state, command) do
    Task.Supervisor.async_nolink(
      @task_supervisor,
      fn ->
        state.commands_module.handle_command(command)
      end
    )
  end

  defp finish_command(state, command) do
    state
    |> state.commands_module.unlock(command)
    |> next_command()
  end
end
