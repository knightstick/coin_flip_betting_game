defmodule CoinFlipBettingGame do
  alias CoinFlipBettingGame.Boundary.TableSession

  def join_table(table_name, player) do
    TableSession.join_or_create(table_name, player)
  end

  def bet(table_name, player, {_, _} = bet) do
    TableSession.bet(table_name, player, bet)
  end

  def flip_and_pay(table_name) do
    TableSession.flip_and_pay(table_name)
  end

  def cash_out(table_name, player) do
    TableSession.cash_out(table_name, player)
  end
end
