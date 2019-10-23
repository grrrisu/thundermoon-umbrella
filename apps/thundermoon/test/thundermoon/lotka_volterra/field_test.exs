defmodule Thundermoon.FieldTest do
  use ExUnit.Case, async: true

  alias Thundermoon.Field
  alias ThundermoonWeb.Endpoint

  setup do
    {:ok, field} = Field.start()
    Endpoint.subscribe("Thundermoon.LotkaVolterra")

    on_exit(fn ->
      :ok = Agent.stop(field)
      Endpoint.unsubscribe("Thundermoon.LotkaVolterra")
    end)

    %{field: field}
  end

  defp assert_broadcast_vegetation(value) do
    assert_received %Phoenix.Socket.Broadcast{
      event: "update",
      payload: %{vegetation: ^value},
      topic: "Thundermoon.LotkaVolterra"
    }
  end

  test "size increases by delta after 1 tick", %{field: field} do
    assert 650 + 32.5 == Field.tick(field)
    assert_broadcast_vegetation(650 + 32.5)
  end
end
