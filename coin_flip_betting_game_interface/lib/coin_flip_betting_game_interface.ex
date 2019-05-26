defmodule CoinFlipBettingGameInterface do
  @moduledoc """
  CoinFlipBettingGameInterface keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def get_table_sessions() do
    CoinFlipBettingGame.list_tables()
  end
end