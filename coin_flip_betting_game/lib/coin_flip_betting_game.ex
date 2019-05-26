defmodule CoinFlipBettingGame do
  alias CoinFlipBettingGame.Boundary.{TableSession, Publisher}
  alias CoinFlipBettingGame.Core.{Bets, Table}

  def list_tables() do
    TableSession.list_tables()
  end

  def join_table(table_name, player) do
    with %Table{} = table <- TableSession.join_or_create(table_name, player),
         # TODO: money
         :ok <- Publisher.publish_event(table_name, {:player_joined, {table.name, player}}) do
      table
    end
  end

  def bet(table_name, player, {_, _} = bet) do
    with %Bets{} = bets <- TableSession.bet(table_name, player, bet),
         :ok <- Publisher.publish_event(table_name, {:bet_placed, {table_name, player, bet}}) do
      bets
    end
  end

  def flip_and_pay(table_name) do
    with %Table{} = table <- TableSession.flip_and_pay(table_name),
         :ok <- Publisher.publish_event(table_name, {:bets_paid, {table.name, table.bets}}) do
      table
    end
  end

  def cash_out(table_name, player) do
    with returned_stake = TableSession.cash_out(table_name, player),
         :ok <- Publisher.publish_event(table_name, {:player_left, {table_name, player}}) do
      returned_stake
    end
  end

  def subscribe_to_table_events(table_name, pid) do
    Publisher.subscribe(table_name, pid)
  end
end
