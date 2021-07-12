defmodule ThundermoonWeb.Component.Form.TextInput do
  use ThundermoonWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> set_label(assigns)}
  end

  def set_label(socket, %{opts: [label: label]}) do
    assign(socket, label: label)
  end

  def set_label(socket, %{field: field}) when is_atom(field) do
    assign(socket, label: field |> Atom.to_string() |> String.capitalize())
  end

  def render(assigns) do
    ~L"""
    <label for="<%= @field %>"><%= @label %></label>
    <%= text_input @form, @field, @opts %>
    <%= error_tag(@form, @field) %>
    """
  end
end
