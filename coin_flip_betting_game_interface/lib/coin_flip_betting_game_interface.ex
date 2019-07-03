defmodule CoinFlipBettingGameInterface do
  alias CoinFlipBettingGameInterface.RandomName

  @moduledoc """
  CoinFlipBettingGameInterface keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def get_table_sessions() do
    CoinFlipBettingGame.list_tables()
  end

  def create_table_session() do
    CoinFlipBettingGame.join_table(random_table_name(), web_player())
  end

  defp random_table_name() do
    RandomName.pick()
  end

  defp web_player() do
    "phoenix-user"
  end
end
