defmodule ThundermoonWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  def live_flash_alerts(assigns) do
    live_component(ThundermoonWeb.Component.FlashAlert, assigns)
  end

  def live_text_input(form, field, opts \\ []) do
    live_component(ThundermoonWeb.Component.Form.TextInput,
      form: form,
      field: field,
      opts: opts
    )
  end

  def start_button(id, started) do
    live_component(ThundermoonWeb.Component.StartButton, id: id, started: started)
  end
end
