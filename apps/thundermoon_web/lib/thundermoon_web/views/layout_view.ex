defmodule ThundermoonWeb.LayoutView do
  use ThundermoonWeb, :view

  def signed_in?(conn) do
    Map.get(conn.assigns, :signed_in)
  end
end
