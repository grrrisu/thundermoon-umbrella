defmodule Sim.Laboratory.Registry do
  alias Sim.Laboratory.{InVitro, InVitroSupervisor}

  # 1 hour in seconds
  @expires_in 60 * 60

  def create(state, pub_sub) do
    id = generate_token()
    {:ok, pid} = create_entry(id, pub_sub)
    ref = Process.monitor(pid)
    entry = %{id: id, pid: pid, ref: ref, timestamp: DateTime.utc_now()}
    {{:ok, entry}, update_state(state, entry)}
  end

  def get(state, id) do
    case Map.get(state, id) do
      nil -> {:error, :not_found}
      entry -> entry
    end
  end

  def find_by_ref(state, ref) do
    Enum.find(state, fn {_key, value} -> value.ref == ref end)
  end

  def update_object(state, id, func) when is_function(func) do
    case Map.get(state, id) do
      nil ->
        {{:error, :not_found}, state}

      entry ->
        GenServer.call(entry.pid, {:update_object, func})
    end
  end

  def update(state, id, key, value) do
    case Map.get(state, id) do
      nil ->
        {{:error, :not_found}, state}

      entry ->
        new_entry = Map.put(entry, key, value)
        {new_entry, update_state(state, new_entry)}
    end
  end

  def delete(state, id) do
    case Map.get(state, id) do
      nil ->
        {{:error, :not_found}, state}

      entry ->
        :ok = DynamicSupervisor.terminate_child(InVitroSupervisor, entry.pid)
        {:ok, Map.delete(state, id)}
    end
  end

  def prune(state) do
    DateTime.utc_now()
    |> DateTime.add(-@expires_in)
    |> terminate_expired(state)
  end

  defp terminate_expired(expire_date, state) do
    Enum.reduce(state, state, fn {_key, item}, state ->
      case DateTime.compare(item.timestamp, expire_date) do
        :lt ->
          {:ok, state} = delete(state, item.id)
          state

        _ ->
          state
      end
    end)
  end

  defp create_entry(id, pub_sub) do
    DynamicSupervisor.start_child(InVitroSupervisor, {InVitro, entry_id: id, pub_sub: pub_sub})
  end

  defp update_state(state, entry) do
    Map.put(state, entry.id, entry)
  end

  defp generate_token do
    :crypto.strong_rand_bytes(16) |> :crypto.bytes_to_integer() |> Integer.to_string()
  end
end
