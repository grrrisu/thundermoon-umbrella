defmodule Thundermoon.Memo.Registry do
  def create() do
    pid = DynamicSupervisor.start_child(InVitro, [])
    ref = Process.monitor(pid)
    %{pid: pid, ref: ref, timestamp: DateTime.utc_now()}
  end

  def update(entry, key, value) do
    Map.put(entry, key, value)
  end
end
