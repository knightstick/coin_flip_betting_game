defmodule CoinFlipBettingGame do
  alias CoinFlipBettingGame.Boundary.TableSession

  def join_table(table_name, player) do
    TableSession.join_or_create(table_name, player)
  end
end
