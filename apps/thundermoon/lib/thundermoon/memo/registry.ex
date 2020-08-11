defmodule Thundermoon.Memo.Registry do
  def create() do
    %{id: generate_token()}
  end

  def update(entry, key, value) do
    Map.put(entry, key, value)
  end

  defp generate_token do
    :crypto.strong_rand_bytes(16) |> :crypto.bytes_to_integer()
  end
end
