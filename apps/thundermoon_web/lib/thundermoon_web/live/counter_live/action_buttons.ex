defmodule ThundermoonWeb.CounterLive.ActionButtons do
  use Phoenix.Component
  use Phoenix.HTML

  import Canada.Can

  alias ThundermoonWeb.Component.Actions

  def box(assigns) do
    ~H"""
      <div>
        <Actions.box>
          <Actions.start_button started={@started} />
          <Actions.reset_button :if={can?(@current_user, :reset, Thundermoon.Counter)}/>
        </Actions.box>
      </div>
    """
  end
end
