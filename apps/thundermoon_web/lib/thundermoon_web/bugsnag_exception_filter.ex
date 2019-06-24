defmodule ThundermoonWeb.BugsnagExceptionFilter do
  def should_notify({{%{plug_status: response_status}, _}, _}, _stacktrace)
      when is_integer(response_status) do
    # structure used by cowboy 2.0
    response_status < 400 or response_status >= 500
  end

  def should_notify(_e, _s), do: true
end
