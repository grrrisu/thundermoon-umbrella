defmodule ThundermoonWebViewHelper do
  import Phoenix.HTML.Tag, only: [content_tag: 3]

  def start_button(state) do
    icon = if state == "start", do: "la-play", else: "la-pause"

    content_tag(:a, [
      {"phx-click", "toggle-sim-start"},
      {"phx-value-action", state},
      {:class, "button button-icon"}
    ]) do
      [
        content_tag(:i, "", class: "la la-2x #{icon}"),
        " #{state}"
      ]
    end
  end

  def signed_in?(conn) do
    Map.get(conn.assigns, :current_user)
  end
end
