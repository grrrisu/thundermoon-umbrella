defmodule ThundermoonWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  def live_text_input(form, field, opts \\ []) do
    live_component(ThundermoonWeb.Component.Form.TextInput,
      form: form,
      field: field,
      opts: Keyword.merge([class: "input text-input mb-3"], opts)
    )
  end

  def start_button(id, started) do
    live_component(ThundermoonWeb.Component.StartButton, id: id, started: started)
  end
end
