defmodule ThundermoonWeb.GameOfLifeLive.ActionButtons do
  use Phoenix.Component

  import Canada.Can

  alias ThundermoonWeb.Component.Actions

  def box(assigns) do
    ~H"""
    <div>
      <Actions.box>
        <Actions.start_button started={@started} />
        <Actions.recreate_button />
        <Actions.clear_button />
        <%= if can?(@current_user, :create, GameOfLife) do %>
          <Actions.reset_button />
        <% end %>
      </Actions.box>
    </div>
    """
  end
end
