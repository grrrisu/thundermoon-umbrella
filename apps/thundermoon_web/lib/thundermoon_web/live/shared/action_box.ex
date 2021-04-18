defmodule ThundermoonWeb.Component.ActionBox do
  use ThundermoonWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="border bg-gray-800 border-gray-600 rounded-md py-4 px-8">
      <%= render_block(@inner_block) %>
    </div>
    """
  end

end
