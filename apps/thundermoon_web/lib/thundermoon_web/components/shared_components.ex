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
  slot :inner_block, required: true

  def text_section(assigns) do
    ~H"""
    <div class="w-full xl:w-4/5 mx-auto">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :link, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :icon, :string, required: true

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

  def local? do
    Endpoint.url() =~ "localhost"
  end
end
