defmodule ThundermoonWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  def live_text_input(socket, form, field, opts \\ []) do
    live_component(socket, ThundermoonWeb.Component.Form.TextInput,
      form: form,
      field: field,
      opts: opts
    )
  end

  def start_button(socket, id, started) do
    live_component(socket, ThundermoonWeb.Component.StartButton, id: id, started: started)
  end
end
