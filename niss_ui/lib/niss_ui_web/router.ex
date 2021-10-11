defmodule NissUiWeb.Router do
  use NissUiWeb, :router
  alias NissUiWeb.EnsureAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {NissUiWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public
  scope "/", NissUiWeb do
    pipe_through :browser

    get "/auth/login", Auth, :login
    post "/auth/login", Auth, :login_post

    live "/public", Live.Page.Public, :index
  end

  # Authed
  scope "/", NissUiWeb do
    pipe_through [:browser, EnsureAuth]

    live "/", Live.Page.Home, :index
    get "/auth/logout", Auth, :logout
    live_dashboard "/dashboard", metrics: NissUiWeb.Telemetry
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
