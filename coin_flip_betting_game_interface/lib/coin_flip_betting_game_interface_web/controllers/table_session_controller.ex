defmodule CoinFlipBettingGameInterfaceWeb.TableSessionController do
  use CoinFlipBettingGameInterfaceWeb, :controller

  def index(conn, _params) do
    table_sessions = CoinFlipBettingGameInterface.get_table_sessions()
    render(conn, "index.html", table_sessions: table_sessions)
  end

  def create(conn, params) do
    CoinFlipBettingGameInterface.create_table_session()
    table_sessions = CoinFlipBettingGameInterface.get_table_sessions()
    render(conn, "index.html", table_sessions: table_sessions)
  end
end
