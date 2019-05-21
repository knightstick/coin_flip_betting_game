defmodule TableTest do
  use ExUnit.Case

  alias CoinFlipBettingGame.Core.Table

  describe "join" do
    test "joining adds name to list of players" do
      table = Table.new("table1") |> Table.join("chris", 1000)
      assert "chris" in table.players

      table = table |> Table.join("erin", 1000)
      assert "erin" in table.players
    end

    test "joining adds stake to bets" do
      table = Table.new("table1") |> Table.join("chris", 1000)

      assert stakes(table, "chris") == 1000
    end
  end

  describe "bet" do
    setup [:table]

    test "adds bet to wagers", %{table: table} do
      table = Table.bet(table, "chris", {:heads, 500})
      assert {"chris", {:heads, 500}} in wagers(table)
    end

    test "removes bet from stakes", %{table: table} do
      table = Table.bet(table, "chris", {:heads, 500})
      assert stakes(table, "chris") == 1000 - 500
    end

    test "cannot bet more than staked", %{table: table} do
      assert {:error, _} = Table.bet(table, "chris", {:heads, 10_000})
    end
  end

  describe "flip_and_pay" do
    setup [:table_with_bet]

    test "adds or subtracts from stake", %{table: table} do
      table = Table.flip_and_pay(table)
      # Either plus or minus 250, based on value
      assert stakes(table, "chris") in [1000 - 250, 1000 + 250]
    end

    test "clears wagers", %{table: table} do
      table = Table.flip_and_pay(table)
      assert wagers(table) == []
    end
  end

  describe "cash_out" do
    setup [:table_with_bets]

    test "removes player from players", %{table: table} do
      table = Table.cash_out(table, "chris")
      refute "chris" in table.players
      assert "erin" in table.players
    end

    test "removes player from stakes", %{table: table} do
      table = Table.cash_out(table, "chris")
      refute Map.has_key?(table.bets.stakes, "chris")
      assert Map.has_key?(table.bets.stakes, "erin")
    end

    test "removes all (and only) player's wagers", %{table: table} do
      table = Table.cash_out(table, "chris")
      refute "chris" in wagering_players(table)
      assert "erin" in wagering_players(table)
    end
  end

  defp table_with_players(players) do
    players
    |> Enum.reduce(Table.new("table1"), fn player, table ->
      Table.join(table, player, 1000)
    end)
  end

  defp stakes(table, player) do
    table.bets.stakes[player]
  end

  defp wagers(table) do
    table.bets.wagered
  end

  defp wagering_players(table) do
    table.bets.wagered
    |> Enum.reduce([], fn {player, _}, acc -> [player | acc] end)
    |> Enum.uniq()
  end

  defp table(context) do
    players = ["chris"]
    {:ok, Map.put(context, :table, table_with_players(players))}
  end

  defp table_with_bet(context) do
    players = ["chris"]
    table = table_with_players(players) |> Table.bet("chris", {:heads, 250})
    {:ok, Map.put(context, :table, table)}
  end

  defp table_with_bets(context) do
    players = ["chris", "erin"]
    table = table_with_players(players)
    |> Table.bet("chris", {:heads, 250})
    |> Table.bet("chris", {:heads, 150})
    |> Table.bet("chris", {:tails, 150})
    |> Table.bet("erin", {:tails, 150})
    {:ok, Map.put(context, :table, table)}
  end
end
