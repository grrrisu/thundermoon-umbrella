defmodule ThundermoonWeb.CounterLive.ActionButtons do
  use Phoenix.Component
  use Phoenix.HTML

  import Canada.Can

  import ThundermoonWeb.Component.Actions

  def action_buttons(assigns) do
    ~H"""
    <div>
      <.box>
        <.start_button started={@started} />
        <.reset_button :if={can?(@current_user, :reset, Thundermoon.Counter)} />
      </.box>
    </div>
    """
  end
end
