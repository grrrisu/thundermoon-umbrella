defmodule Test.Realm do
  use Sim.Realm, app_module: __MODULE__

  def crash() do
    send_command({:test, :crash})
  end

  def echo(payload) do
    send_command({:test, :echo, payload: payload})
  end

  def echo_twice(payload) do
    send_command({:test, :echo_twice, payload: payload})
  end
end
