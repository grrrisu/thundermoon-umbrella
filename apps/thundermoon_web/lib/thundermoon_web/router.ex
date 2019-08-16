defmodule ThundermoonWeb.Router do
  use ThundermoonWeb, :router
  use Plugsnag

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :public do
    plug :browser
  end

  pipeline :private do
    plug :browser

    if Mix.env() == :test do
      plug ThundermoonWeb.BackdoorAuthPlug
    end

    plug ThundermoonWeb.AuthPlug
  end

  scope "/", ThundermoonWeb do
    pipe_through :public

    get "/", PageController, :index

    get "/auth/github", AuthController, :request
    get "/auth/github/callback", AuthController, :callback
    delete "/auth", AuthController, :delete
  end

  scope "/", ThundermoonWeb do
    pipe_through :private

    get "/dashboard", PageController, :dashboard
    resources "/users", UserController, only: [:index, :edit, :update, :delete]
    live "/chat", ChatLive, session: [:current_user_id]
  end
end
