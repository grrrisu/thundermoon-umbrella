defmodule ThundermoonWeb.Component.Form.TextInput do
  use ThundermoonWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> set_errors(assigns)
     |> set_input_css()
     |> set_label(assigns)}
  end

  def set_errors(socket, %{form: form, field: field}) do
    assign(socket, :has_errors, Keyword.has_key?(form.errors, field))
  end

  def set_input_css(%{assigns: %{has_errors: true, opts: _opts}} = socket) do
    assign(socket, input_css: "input-error text-input")
  end

  def set_input_css(%{assigns: %{has_errors: false, opts: _opts}} = socket) do
    assign(socket, input_css: "input text-input")
  end

  def set_label(socket, %{opts: [label: label]}) do
    assign(socket, label: label)
  end

  def set_label(socket, %{field: field}) when is_atom(field) do
    assign(socket,
      label: field |> Atom.to_string() |> String.capitalize() |> String.replace("_", " ")
    )
  end

  def render(assigns) do
    ~L"""
    <div class="mb-3">
      <label for="<%= @field %>"><%= @label %></label>
      <%= text_input @form, @field, class: @input_css %>
      <%= error_tag(@form, @field) %>
    </div>
    """
  end
end
