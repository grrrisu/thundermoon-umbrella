defmodule ThundermoonWeb.Component.FlashAlert do
  use ThundermoonWeb, :live_component

  def alert(alerts, type) do
    alerts[Atom.to_string(type)]
  end

  def render(assigns) do
    ~L"""
    <%= if alert(@alert, :info) do %>
    <p class="rounded bg-blue-400 text-blue-900 py-3 px-4" phx-click="lv:clear-flash" phx-value-key="info">
      <%= alert(@alert, :info) %>
    </p>
    <% end %>
    <%= if alert(@alert, :error) do %>
    <p class="rounded bg-red-300 text-red-900 py-3 px-4" phx-click="lv:clear-flash" phx-value-key="error">
      <%= alert(@alert, :error) %>
    </p>
    <% end %>
    """
  end
end
