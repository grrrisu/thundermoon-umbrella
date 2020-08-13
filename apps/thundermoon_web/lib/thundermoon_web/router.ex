defmodule ThundermoonWeb.Router do
  use ThundermoonWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ThundermoonWeb.AuthPlug
    plug :put_root_layout, {ThundermoonWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :public do
    plug :browser
  end

  pipeline :private do
    plug :browser
    plug ThundermoonWeb.MemberareaPlug
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
    live "/chat", ChatLive
    live "/counter", CounterLive
    live "/game_of_life", GameOfLifeLive
    live "/lotka-volterra", LotkaVolterra.Index
  end

  if Mix.env() != :prod do
    scope "/" do
      pipe_through :private
      live_dashboard "/live_dashboard", metrics: ThundermoonWeb.Telemetry
    end
  end

  if Mix.env() == :integration do
    scope "/api", ThundermoonWeb do
      pipe_through :api

      post "/login", Api.IntegrationController, :authorize
      delete "/logout", Api.IntegrationController, :clear_session
      patch "/game_of_life/restart", Api.IntegrationController, :restart_game_of_life
      post "/game_of_life/create", Api.IntegrationController, :create_game_of_life
    end
  end
end
