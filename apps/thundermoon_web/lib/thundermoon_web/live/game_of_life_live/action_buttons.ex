defmodule ThundermoonWeb.GameOfLifeLive.ActionButtons do
  use Phoenix.Component

  import Canada.Can

  import ThundermoonWeb.Component.Actions

  def action_buttons(assigns) do
    ~H"""
    <div>
      <.box>
        <.start_button started={@started} />
        <.recreate_button />
        <.clear_button />
        <.reset_button :if={can?(@current_user, :create, GameOfLife)}/>
      </.box>
    </div>
    """
  end
end
