defmodule CoinFlipBettingGameWebWeb.PageController do
  use CoinFlipBettingGameWebWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
