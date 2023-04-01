defmodule ThundermoonWeb.PageHTML do
  use ThundermoonWeb, :html

  embed_templates "page_html/*"

  attr :title, :string, required: true
  slot :inner_block

  def hero_section(assigns) do
    ~H"""
    <section class="bg-gray-700 my-8 p-8 rounded-lg shadow-lg text-center">
      <h1 class="text-4xl font-semibold mb-4"><%= @title %></h1>
      <p :if={@inner_block}><%= render_slot(@inner_block) %></p>
    </section>
    """
  end
end
