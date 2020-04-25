defmodule ThundermoonWeb.PageView do
  use ThundermoonWeb, :view
  import ThundermoonWebViewHelper

  def local? do
    ThundermoonWeb.Endpoint.url() =~ "localhost"
  end
end
