defmodule ThundermoonWeb.Component.Actions do
  use Phoenix.Component

  def box(assigns) do
    ~H"""
    <div class="border bg-gray-800 border-gray-600 rounded-md py-4 px-8">
      <%= render_block(@inner_block) %>
    </div>
    """
  end

  def start_button(assigns) do
    assigns =
      assign(assigns,
        label: start_label(assigns.started),
        action: start_action(assigns.started),
        icon: start_icon(assigns.started)
      )

    ~H"""
    <a href="#" id="start-button" phx-click={@action} phx-value-action={@label} class="btn btn-primary">
      <i class={"align-middle la text-xl #{@icon}"}></i><%= @label %>
    </a>
    """
  end

  defp start_action(false), do: "start"
  defp start_action(true), do: "stop"

  defp start_icon(false), do: "la-play"
  defp start_icon(true), do: "la-pause"

  defp start_label(false), do: "start"
  defp start_label(true), do: "stop"
end
