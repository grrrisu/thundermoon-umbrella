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
            <%= link to: "#", id: "reset-button", phx_click: "reset", class: "btn btn-warning" do %>
              <i class="align-middle text-xl la la-reply"></i> reset
            <% end %>
          <% end %>
        </Actions.box>
      </div>
    """
  end

  def can?(current_user, action) do
    can?(current_user, action, Thundermoon.Counter)
  end
end
