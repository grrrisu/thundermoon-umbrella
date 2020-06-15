defmodule ThundermoonWeb.PageView do
  use ThundermoonWeb, :view
  import ThundermoonWebViewHelper

  alias ThundermoonWeb.Endpoint

  def local? do
    Endpoint.url() =~ "localhost"
  end
end
