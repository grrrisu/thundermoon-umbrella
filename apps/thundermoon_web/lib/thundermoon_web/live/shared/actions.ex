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

  def recreate_button(assigns) do
    ~H"""
    <a href="#" id="recreate-button" phx-click="recreate" class="btn btn-warning">
      <i class="align-middle text-xl la la-reply"></i> recreate
    </a>
    """
  end

  def clear_button(assigns) do
    ~H"""
    <a href="#" id="clear-button" phx-click="clear" class="btn btn-warning">
      <i class="align-middle text-xl la la-eraser"></i> clear
    </a>
    """
  end

  def reset_button(assigns) do
    ~H"""
    <a href="#" id="reset-button" phx-click="reset" class="btn btn-warning">
      <i class="align-middle text-xl la la-reply-all"></i> reset
    </a>
    """
  end
end
