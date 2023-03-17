defmodule ThundermoonWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  def live_text_input(form, field, opts \\ []) do
    live_component(ThundermoonWeb.Component.Form.TextInput,
      form: form,
      field: field,
      opts: opts
    )
  end
end
