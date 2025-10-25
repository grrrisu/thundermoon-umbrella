defmodule ThundermoonWeb.FormComponents do
  @moduledoc """
  Provides form components.

  This are Thundermoon specific components
  """
  use Phoenix.Component

  alias Phoenix.HTML.{Form, FormField}

  slot :row, required: true
  slot :inner_block, required: true

  def fieldset(assigns) do
    ~H"""
    <fieldset>
      <div :for={row <- @row} class="mb-3">
        {render_slot(row)}
      </div>
      {render_slot(@inner_block)}
    </fieldset>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `%Phoenix.HTML.Form{}` and field name may be passed to the input
  to build input names and error messages, or all the attributes and
  errors may be passed explicitly.

  ## Examples

      <.input field={@form[:email]} type="email" />
      #<.input name="my-input" errors={["oh no!"]} />
  """
  attr :field, :any
  attr :label, :string, default: nil
  attr :id, :any, default: nil
  attr :value, :any, default: nil
  attr :class, :string, default: nil

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
  range radio search select tel text textarea time url week)

  attr :rest, :global, include: ~w(autocomplete cols disabled form max maxlength min minlength
                                   pattern placeholder readonly required rows size step)

  def text_input(%{field: %FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns =
      assign(assigns,
        value: assigns.value || Form.normalize_value(assigns.type, field.value),
        name: field.name,
        id: assigns.id || field.id || field.name,
        errors: Enum.map(errors, &translate_error(&1)),
        input_bg_color:
          if(field.errors == [],
            do: "bg-gray-700 focus:bg-gray-600",
            else: "bg-pink-800 focus:bg-pink-700"
          )
      )

    ~H"""
    <div class={["w-full", @class]}>
      <.label :if={@label} for={@id}>{@label}</.label>
      <input
        type={@type}
        value={@value}
        name={@name}
        id={@id}
        class={[
          "text-gray-100 focus:outline-none w-full",
          "font-light p-2 rounded-md focus:shadow-inner focus:ring-1 focus:ring-gray-400",
          @input_bg_color
        ]}
        {@rest}
      />
      <.form_error :for={msg <- @errors}>{msg}</.form_error>
    </div>
    """
  end

  attr :for, :string
  slot :inner_block

  def label(assigns) do
    ~H"""
    <label for={@for}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  slot :inner_block

  def form_error(assigns) do
    ~H"""
    <span class="text-pink-400">{render_slot(@inner_block)}</span>
    """
  end

  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(ThundermoonWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(ThundermoonWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
