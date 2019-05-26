defmodule CoinFlipBettingGameInterfaceWeb.PageController do
  use CoinFlipBettingGameInterfaceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
