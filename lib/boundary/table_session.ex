defmodule CoinFlipBettingGame.Boundary.TableSession do
  use GenServer

  alias CoinFlipBettingGame.Core.Table

  def init(table) do
    {:ok, table}
  end

  def handle_call({:join_table, player}, _from, table) do
    table = Table.join(table, player, default_stake())
    {:reply, table.bets.stakes, table}
  end

  def handle_call({:bet, player, {_, _} = bet}, _from, table) do
    table = Table.bet(table, player, bet)
    {:reply, table.bets, table}
  end

  def handle_call(:flip_and_pay, _from, table) do
    table = Table.flip_and_pay(table)
    {:reply, table.bets.stakes, table}
  end

  def handle_call({:cash_out, player}, _from, table) do
    table = Table.cash_out(table, player)
    # TODO: return amount of money cashed out
    {:reply, 0, table}
  end

  def join_table(session, player) do
    GenServer.call(session, {:join_table, player})
  end

  def bet(session, player, {_, _} = bet) do
    GenServer.call(session, {:bet, player, bet})
  end

  def flip_and_pay(session) do
    GenServer.call(session, :flip_and_pay)
  end

  def cash_out(session, player) do
    GenServer.call(session, {:cash_out, player})
  end

  defp default_stake() do
    1000
  end
end
