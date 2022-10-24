defmodule ThundermoonWeb.CounterLive.Digit do
  use Phoenix.Component
  use Phoenix.HTML

  def digit(assigns) do
    ~H"""
      <div class="flex flex-col space-y-4">
        <%= link "+", to: "#", id: "#{@id}-inc", class: "btn text-2xl btn-primary", phx_click: "inc", phx_value_digit: @digit %>
        <div id={@id} class="digit font-mono text-6xl"><%= @value %></div>
        <%= link "-", to: "#", id: "#{@id}-dec", class: "btn text-2xl btn-primary", phx_click: "dec", phx_value_digit: @digit %>
    </div>
    """
  end
end
