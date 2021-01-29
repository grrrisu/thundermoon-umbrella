defmodule Sim.Realm.CommandFanTest do
  use ExUnit.Case, async: false

  alias Sim.Realm.CommandFan

  describe "init" do
    setup do
      state = %{
        sim: %{
          module: SimService,
          running_command: nil,
          running_ref: nil,
          queue: :queue.new()
        },
        action: %{
          module: ActionService,
          running_command: nil,
          running_ref: nil,
          queue: :queue.new()
        }
      }

      %{state: state}
    end

    test "init services", %{state: state} do
      services = %{sim: SimService, action: ActionService}
      initialized_state = CommandFan.init_services(services)
      assert initialized_state == state
    end
  end

  describe "dispatch command" do
    setup do
      {:ok, task_supervisor} = start_supervised(Task.Supervisor)
      {:ok, task_pid} = Task.start(fn -> :nothing end)
      task_ref = Process.monitor(task_pid)

      state = %{
        services: %{
          sim: %{
            module: SimService,
            running_command: nil,
            running_ref: nil,
            queue: :queue.new()
          },
          action: %{
            module: ActionService,
            running_command: {:action, :move, x: 7, y: 3},
            running_ref: "a_ref",
            queue: :queue.new()
          },
          admin: %{
            module: AdminService,
            running_command: {:admin, :create, size: 25},
            running_ref: task_ref,
            queue: :queue.from_list([{:admin, :start_sim, []}])
          }
        },
        task_supervisor_module: task_supervisor
      }

      %{state: state, task_ref: task_ref}
    end

    test "queue if another command of the same service is already running", %{state: state} do
      command = {:action, :move, x: 5, y: 5}
      assert {:reply, :ok, state} = CommandFan.handle_call({:dispatch, command}, "from", state)

      assert :queue.to_list(state.services.action.queue) == [command]
      assert state.services.action.running_command == {:action, :move, x: 7, y: 3}
    end

    test "execute command if for this services no other task is running", %{state: state} do
      command = {:sim, :world}
      assert {:reply, :ok, state} = CommandFan.handle_call({:dispatch, command}, "from", state)

      assert :queue.len(state.services.sim.queue) == 0
      assert is_reference(state.services.sim.running_ref)
      assert state.services.sim.running_command == {:sim, :world, []}
    end

    test "execute next command after task has finished", %{state: state, task_ref: task_ref} do
      {:noreply, state} = CommandFan.handle_info({task_ref, ["an_event"]}, state)

      assert state.services.admin.running_command == {:admin, :start_sim, []}
      assert is_reference(state.services.admin.running_ref)
      assert :queue.len(state.services.admin.queue) == 0
    end

    test "execute next command even after task has failed", %{state: state, task_ref: task_ref} do
      {:noreply, state} =
        CommandFan.handle_info({:DOWN, task_ref, :process, "pid", :error}, state)

      assert state.services.admin.running_command == {:admin, :start_sim, []}
      assert is_reference(state.services.admin.running_ref)
      assert :queue.len(state.services.admin.queue) == 0
    end
  end
end
