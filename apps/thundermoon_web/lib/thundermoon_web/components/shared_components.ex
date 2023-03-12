defmodule ThundermoonWeb.SharedComponents do
  @moduledoc """
  Provides core UI components.

  This are Thundermoon specific components
  """
  use Phoenix.Component

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

  def signed_in?(conn) do
    Map.get(conn.assigns, :current_user)
  end
end
