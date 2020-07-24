defmodule ThundermoonWeb.SentryEventFilter do
  @behaviour Sentry.EventFilter

  # Ignore Phoenix route not found exception
  def exclude_exception?(%x{}, :plug) when x in [Phoenix.Router.NoRouteError] do
    true
  end

  # Ignore Plug route not found exception
  def exclude_exception?(%FunctionClauseError{function: :do_match, arity: 4}, :plug), do: true
end
