defmodule Sim.Laboratory.Registry do
  alias Sim.Laboratory.{InVitro, InVitroSupervisor}

  # 1 hour in seconds
  @expires_in 60 * 60

  def create(state) do
    {:ok, pid} = DynamicSupervisor.start_child(InVitroSupervisor, InVitro)
    ref = Process.monitor(pid)
    entry = %{id: generate_token(), pid: pid, ref: ref, timestamp: DateTime.utc_now()}
    {{:ok, entry}, update_state(state, entry)}
  end

  def get(state, id) do
    case Map.get(state, id) do
      nil -> {:error, :not_found}
      entry -> entry
    end
  end

  def update(state, id, key, value) do
    case Map.get(state, id) do
      nil ->
        {{:error, :not_found}, state}

      entry ->
        entry = Map.put(entry, key, value)
        {entry, update_state(state, entry)}
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

  defp update_state(state, entry) do
    Map.put(state, entry.id, entry)
  end

  defp generate_token do
    :crypto.strong_rand_bytes(16) |> :crypto.bytes_to_integer()
  end
end
