defmodule Sim.Realm.CommandGuard do
  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, {opts[:commands_module], opts[:task_supervisor_name]},
      name: opts[:name]
    )
  end

  def init({commands_module, task_supervisor_name}) do
    Logger.debug("start command guard with #{commands_module}")

    {:ok,
     %{
       commands_module: commands_module,
       task_supervisor_module: task_supervisor_name,
       pending_commands: :queue.new(),
       current_lock: nil,
       task: {nil, nil}
     }}
  end

  # --- client ---

  def receive(server, command) do
    GenServer.call(server, {:receive, command})
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

    Logger.debug(
      "task executing command #{inspect(command)} finished with result #{inspect(answer)}"
    )

    {:noreply, finish_command(state, command)}
  end

  # The task failed
  def handle_info({:DOWN, ref, :process, _pid, reason}, %{task: {ref, command}} = state) do
    Logger.warn(
      "task executing command #{inspect(command)} failed with reason #{inspect(reason)}"
    )

    {:noreply, finish_command(state, command)}
  end

  def handle_info(:next_command, state) do
    {:noreply, next_command(state)}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp add_command(state, command) do
    %{state | pending_commands: :queue.in(command, state.pending_commands)}
  end

  defp next_command(state) do
    state
    |> launch_command()
    |> more_commands()
  end

  defp launch_command(state) do
    with {{:value, command}, queue} <- :queue.out(state.pending_commands),
         {:ok, new_lock} <- state.commands_module.lock(state, command) do
      task = execute_command(state, command)
      %{state | pending_commands: queue, current_lock: new_lock, task: {task.ref, command}}
    else
      {:empty, _queue} -> state
      {:locked, _current_lock} -> state
    end
  end

  defp more_commands(state) do
    if not :queue.is_empty(state.pending_commands) do
      Process.send_after(self(), :next_command, 10)
    end

    state
  end

  defp execute_command(state, command) do
    Task.Supervisor.async_nolink(
      state.task_supervisor_module,
      fn ->
        state.commands_module.handle_command(command)
      end
    )
  end

  defp finish_command(state, command) do
    send(self(), :next_command)

    state
    |> state.commands_module.unlock(command)
    |> remove_task(command)
  end

  defp remove_task(state, _command) do
    %{state | task: {nil, nil}}
  end
end
