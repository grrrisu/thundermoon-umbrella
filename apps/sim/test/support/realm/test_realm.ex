defmodule Test.Realm do
  use Sim.Realm, app_module: __MODULE__

  def crash() do
    send_command(%{command: :crash})
  end
end
