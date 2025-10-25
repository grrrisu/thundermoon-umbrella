defmodule ThundermoonWeb.CounterLive.Digit do
  use ThundermoonWeb, :html

  def digit(assigns) do
    ~H"""
    <div class="flex flex-col space-y-4">
      <.button
        id={"#{@id}-inc"}
        class="text-2xl"
        color="primary"
        phx-click="inc"
        phx-value-digit={@digit}
      >
        +
      </.button>
      <div id={@id} class="digit font-mono text-6xl">{@value}</div>
      <.button
        id={"#{@id}-dec"}
        class="text-2xl"
        color="primary"
        phx-click="dec"
        phx-value-digit={@digit}
      >
        -
      </.button>
    </div>
    """
  end
end
