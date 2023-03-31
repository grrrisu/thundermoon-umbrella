defmodule ThundermoonWeb.Component.Actions do
  use ThundermoonWeb, :html

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
        icon: start_icon(assigns.started),
        disable: start_disable(assigns.started)
      )

    ~H"""
    <.button
      id="start-button"
      phx-click={@action}
      phx-value-action={@label}
      phx-disable-with={@disable}
      class="phx-click-loading:animate-pulse"
    >
      <i class={"align-middle la text-xl #{@icon}"}></i><%= @label %>
    </.button>
    """
  end

  defp start_action(false), do: "start"
  defp start_action(true), do: "stop"

  defp start_icon(false), do: "la-play"
  defp start_icon(true), do: "la-pause"

  defp start_label(false), do: "start"
  defp start_label(true), do: "stop"

  defp start_disable(false), do: "starting ..."
  defp start_disable(true), do: "stopping ..."

  def recreate_button(assigns) do
    ~H"""
    <.button id="recreate-button" phx-click="recreate" color="warning">
      <i class="align-middle text-xl la la-reply"></i> recreate
    </.button>
    """
  end

  def clear_button(assigns) do
    ~H"""
    <.button id="clear-button" phx-click="clear" color="warning">
      <i class="align-middle text-xl la la-eraser"></i> clear
    </.button>
    """
  end

  def reset_button(assigns) do
    ~H"""
    <.button id="reset-button" phx-click="reset" color="warning">
      <i class="align-middle text-xl la la-reply-all"></i> reset
    </.button>
    """
  end
end
