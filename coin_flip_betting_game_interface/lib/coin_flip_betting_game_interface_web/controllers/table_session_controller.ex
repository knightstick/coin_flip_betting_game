defmodule CoinFlipBettingGameInterfaceWeb.TableSessionController do
  use CoinFlipBettingGameInterfaceWeb, :controller

  def index(conn, _params) do
    table_sessions = CoinFlipBettingGameInterface.get_table_sessions()
    render(conn, "index.html", table_sessions: table_sessions)
  end

  def show(conn, %{"id" => id}) do
    table = CoinFlipBettingGameInterface.get_table(id)
    render(conn, "show.html", table_session: table)
  end

  def flip(conn, %{"table_session_id" => id}) do
    table = CoinFlipBettingGameInterface.flip_coin_on_table(id)
    render(conn, "show.html", table_session: table)
  end

  def create(conn, _params) do
    CoinFlipBettingGameInterface.create_table_session()
    table_sessions = CoinFlipBettingGameInterface.get_table_sessions()
    render(conn, "index.html", table_sessions: table_sessions)
  end
end
