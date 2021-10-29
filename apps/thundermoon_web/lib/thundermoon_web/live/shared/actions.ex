defmodule ThundermoonWeb.Component.Actions do
  use Phoenix.Component

  @impl true
  def box(assigns) do
    ~H"""
    <div class="border bg-gray-800 border-gray-600 rounded-md py-4 px-8">
      <%= render_block(@inner_block) %>
    </div>
    """
  end
end
