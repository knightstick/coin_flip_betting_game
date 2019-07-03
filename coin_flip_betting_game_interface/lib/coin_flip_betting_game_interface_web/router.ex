defmodule CoinFlipBettingGameInterfaceWeb.Router do
  use CoinFlipBettingGameInterfaceWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", CoinFlipBettingGameInterfaceWeb do
    pipe_through(:browser)

    get("/", TableSessionController, :index)

    resources("/table-sessions", TableSessionController, only: [:index, :show, :create]) do
      post("/flip", TableSessionController, :flip)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", CoinFlipBettingGameInterfaceWeb do
  #   pipe_through :api
  # end
end
