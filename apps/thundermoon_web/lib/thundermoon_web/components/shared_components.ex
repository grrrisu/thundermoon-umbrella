defmodule ThundermoonWeb.SharedComponents do
  @moduledoc """
  Provides core UI components.

  This are Thundermoon specific components
  """
  use Phoenix.Component

  alias ThundermoonWeb.Endpoint

  @doc """
  a div for a text section
  """
  slot(:inner_block, required: true)

  def text_section(assigns) do
    ~H"""
    <div class="w-full xl:w-4/5 mx-auto">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:link, :string, required: true)
  attr(:title, :string, required: true)
  attr(:description, :string, required: true)
  attr(:icon, :string, required: true)

  def card_section(assigns) do
    ~H"""
    <.link navigate={@link}>
      <div class="bg-indigo-900 rounded ring-1 ring-indigo-400 shadow p-4 h-full hover:bg-indigo-800">
        <i class={"la la-5x #{@icon} ml-3 float-right"}></i>
        <h3 class="text-bold text-xl mb-3"><%= @title %></h3>
        <p class="mb-3"><%= @description %></p>
      </div>
    </.link>
    """
  end

  attr(:flash, :map, default: %{}, doc: "the map of flash messages to display")

  def flash_alert(assigns) do
    ~H"""
    <p
      :if={Phoenix.Flash.get(@flash, :info)}
      class="rounded bg-blue-400 text-blue-900 py-3 px-4"
      phx-click="lv:clear-flash"
      phx-value-key="info"
    >
      <%= Phoenix.Flash.get(@flash, :info) %>
    </p>
    <p
      :if={Phoenix.Flash.get(@flash, :error)}
      class="rounded bg-red-300 text-red-900 py-3 px-4"
      phx-click="lv:clear-flash"
      phx-value-key="error"
    >
      <%= Phoenix.Flash.get(@flash, :error) %>
    </p>
    """
  end

  attr(:class, :string, default: nil)
  attr(:color, :string, default: "primary")
  attr(:rest, :global, include: ~w(disabled form name value))

  slot(:inner_block, required: true)

  def submit(assigns) do
    assigns |> assign(type: "submit") |> button()
  end

  defp button_css("primary") do
    "bg-purple-800 focus:bg-purple-700 focus:ring-offset-purple-400 hover:bg-purple-700"
  end

  defp button_css("warning") do
    "bg-pink-700 focus:bg-pink-600 focus:ring-offset-pink-300 hover:bg-pink-600"
  end

  defp button_css("outline") do
    "bg-gray-800 border border-gray-300 focus:bg-gray-700 focus:ring-offset-gray-200  hover:bg-gray-700"
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr(:type, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:color, :string, default: "primary")
  attr(:rest, :global, include: ~w(disabled form name value))

  slot(:inner_block, required: true)

  def button(assigns) do
    assigns = assign(assigns, color_class: button_css(assigns.color))

    ~H"""
    <button
      type={@type}
      class={[
        "text-gray-100 rounded-md shadow  px-4 py-2 mr-2",
        "phx-submit-loading:opacity-75 focus:ring-1 focus:ring-offset-1 focus:outline-none active:text-white/80",
        @color_class,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  def local? do
    Endpoint.url() =~ "localhost"
  end
end
