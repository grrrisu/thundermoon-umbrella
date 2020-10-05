defmodule ThundermoonWebViewHelper do
  def signed_in?(conn) do
    Map.get(conn.assigns, :current_user)
  end
end
