defmodule Sim.Realm.CommandBusTest do
  use ExUnit.Case, async: false

  alias Sim.Realm.CommandBus

  describe "service state" do
    setup do
      state = %{
        services: %{
          sim: SimService,
          realm: RealmService,
          action: ActionService
        },
        workers: [
          %{
            services: [:realm, :sim],
            running_command: nil,
            running_ref: nil,
            queue: :queue.new()
          },
          %{
            services: [:action],
            running_command: nil,
            running_ref: nil,
            queue: :queue.new()
          }
        ]
      }

      %{state: state}
    end

    test "init services", %{state: state} do
      services = [%{sim: SimService, realm: RealmService}, %{action: ActionService}]
      assert state == CommandBus.init_services(services)
    end

    test "get worker state", %{state: state} do
      state =
        state |> Map.put(:task_supervisor_module, "tsp") |> Map.put(:event_bus_module, "ebm")

      worker_state = %{
        services: [:realm, :sim],
        module: SimService,
        running_command: nil,
        running_ref: nil,
        queue: :queue.new(),
        event_bus_module: "ebm",
        task_supervisor_module: "tsp"
      }

      assert worker_state == CommandBus.assemble_worker_state(:sim, state)
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
          sim: SimService,
          realm: RealmService,
          action: ActionService,
          admin: AdminService
        },
        workers: [
          %{
            services: [:realm, :sim],
            running_command: nil,
            running_ref: nil,
            queue: :queue.new()
          },
          %{
            services: [:action],
            running_command: {:action, :move, x: 7, y: 3},
            running_ref: "a_ref",
            queue: :queue.new()
          },
          %{
            services: [:admin],
            running_command: {:admin, :clear, []},
            running_ref: task_ref,
            queue: :queue.from_list([{:admin, :create, config: 5}])
          }
        ],
        task_supervisor_module: task_supervisor,
        event_bus_module: event_bus
      }

      %{state: state, task_ref: task_ref, event_bus: event_bus}
    end

    test "queue if another command for the same worker is already running", %{state: state} do
      command = {:action, :move, x: 5, y: 5}
      assert {:reply, :ok, state} = CommandBus.handle_call({:dispatch, command}, "from", state)
      worker = CommandBus.assemble_worker_state(:action, state)

      assert :queue.to_list(worker.queue) == [command]
      assert worker.running_command == {:action, :move, x: 7, y: 3}
    end

    test "execute command if for this services no other task is running", %{state: state} do
      command = {:sim, :world}
      assert {:reply, :ok, state} = CommandBus.handle_call({:dispatch, command}, "from", state)
      worker = CommandBus.assemble_worker_state(:sim, state)

      assert :queue.len(worker.queue) == 0
      assert is_reference(worker.running_ref)
      assert worker.running_command == {:sim, :world, []}
    end

    test "execute next command after task has finished", %{state: state, task_ref: task_ref} do
      {:noreply, state} = CommandBus.handle_info({task_ref, :ok}, state)
      worker = CommandBus.assemble_worker_state(:admin, state)

      assert worker.running_command == {:admin, :create, config: 5}
      assert is_reference(worker.running_ref)
      assert :queue.len(worker.queue) == 0
    end

    test "runs immediately sim stop after a task has failed", %{
      state: state,
      task_ref: task_ref,
      event_bus: event_bus
    } do
      {:noreply, state} =
        CommandBus.handle_info({:DOWN, task_ref, :process, "pid", :error}, state)

      worker = CommandBus.assemble_worker_state(:admin, state)

      assert worker.running_command == {:sim, :stop, []}
      assert is_reference(worker.running_ref)
      assert :queue.to_list(worker.queue) == [{:admin, :create, config: 5}]

      assert [{:command_failed, [command: {:admin, :clear, []}, reason: :error]}] ==
               Test.EventBusNull.get_events(event_bus)
    end
  end

  describe "command task" do
    setup do
      {:ok, task_supervisor} = start_supervised(Task.Supervisor)
      {:ok, event_bus} = start_supervised(Test.EventBusNull)

      state = %{
        services: %{
          test: Test.CommandHandler,
          sim: Test.CommandHandler
        },
        workers: [
          %{
            services: [:test, :sim],
            running_command: nil,
            running_ref: nil,
            queue: :queue.new()
          }
        ],
        task_supervisor_module: task_supervisor,
        event_bus_module: event_bus
      }

      %{state: state, event_bus: event_bus}
    end

    test "execute command and add events to event bus", %{state: state, event_bus: event_bus} do
      command = {:test, :echo, payload: "holeridu"}
      worker = CommandBus.assemble_worker_state(:test, state)
      worker = CommandBus.queue_or_execute(worker, command)

      assert worker.running_command == command
      Process.sleep(10)
      assert [{:test, :echoed, payload: "holeridu"}] == Test.EventBusNull.get_events(event_bus)
    end
  end
end
