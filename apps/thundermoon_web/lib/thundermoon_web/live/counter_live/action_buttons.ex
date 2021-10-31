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
          <%= if can?(@current_user, :reset, Thundermoon.Counter) do %>
            <.reset_button current_user={@current_user} />
          <% end %>
        </Actions.box>
      </div>
    """
  end

  def reset_button(assigns) do
    ~H"""
      <%= link to: "#", id: "reset-button", phx_click: "reset", class: "btn btn-warning" do %>
        <i class="align-middle text-xl la la-reply"></i> reset
      <% end %>
    """
  end
end
