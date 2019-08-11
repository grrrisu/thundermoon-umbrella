defmodule ThundermoonWeb.Presence do
  use Phoenix.Presence, otp_app: :thundermoon_web, pubsub_server: ThundermoonWeb.PubSub
end
