defmodule Sim.Realm.CommandBusTest do
  use ExUnit.Case, async: false

  alias Sim.Realm.CommandBus

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
      assert state == CommandBus.init_services(services)
    end
  end

  describe "dispatch command" do
    setup do
      {:ok, task_supervisor} = start_supervised(Task.Supervisor)
      {:ok, event_bus} = start_supervised(Test.EventBusNull)
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
        task_supervisor_module: task_supervisor,
        event_bus_module: event_bus
      }

      %{state: state, task_ref: task_ref, event_bus: event_bus}
    end

    test "queue if another command of the same service is already running", %{state: state} do
      command = {:action, :move, x: 5, y: 5}
      assert {:reply, :ok, state} = CommandBus.handle_call({:dispatch, command}, "from", state)

      assert :queue.to_list(state.services.action.queue) == [command]
      assert state.services.action.running_command == {:action, :move, x: 7, y: 3}
    end

    test "execute command if for this services no other task is running", %{state: state} do
      command = {:sim, :world}
      assert {:reply, :ok, state} = CommandBus.handle_call({:dispatch, command}, "from", state)

      assert :queue.len(state.services.sim.queue) == 0
      assert is_reference(state.services.sim.running_ref)
      assert state.services.sim.running_command == {:sim, :world, []}
    end

    test "execute next command after task has finished", %{state: state, task_ref: task_ref} do
      {:noreply, state} = CommandBus.handle_info({task_ref, :ok}, state)

      assert state.services.admin.running_command == {:admin, :start_sim, []}
      assert is_reference(state.services.admin.running_ref)
      assert :queue.len(state.services.admin.queue) == 0
    end

    test "execute next command even after task has failed", %{
      state: state,
      task_ref: task_ref,
      event_bus: event_bus
    } do
      {:noreply, state} =
        CommandBus.handle_info({:DOWN, task_ref, :process, "pid", :error}, state)

      assert state.services.admin.running_command == {:admin, :start_sim, []}
      assert is_reference(state.services.admin.running_ref)
      assert :queue.len(state.services.admin.queue) == 0

      assert [{:command_failed, [command: {:admin, :create, [size: 25]}, reason: :error]}] ==
               Test.EventBusNull.get_events(event_bus)
    end
  end

  describe "command task" do
    setup do
      {:ok, task_supervisor} = start_supervised(Task.Supervisor)
      {:ok, event_bus} = start_supervised(Test.EventBusNull)

      state = %{
        services: %{
          test: %{
            module: Test.CommandHandler,
            running_command: nil,
            running_ref: nil,
            queue: :queue.new()
          }
        },
        task_supervisor_module: task_supervisor,
        event_bus_module: event_bus
      }

      %{state: state, event_bus: event_bus}
    end

    test "execute command and add events to event bus", %{state: state, event_bus: event_bus} do
      command = {:test, :echo, payload: "holeridu"}

      service_state = CommandBus.queue_or_execute(command, state.services.test, state)
      assert service_state.running_command == command
      Process.sleep(10)
      assert [{:test, :echoed, payload: "holeridu"}] == Test.EventBusNull.get_events(event_bus)
    end
  end
end
