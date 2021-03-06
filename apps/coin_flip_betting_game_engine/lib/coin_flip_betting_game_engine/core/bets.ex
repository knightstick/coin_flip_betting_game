defmodule CoinFlipBettingGameEngine.Core.Bets do
  defstruct stakes: %{}, wagered: []

  def new() do
    %__MODULE__{}
  end

  def join(bets, player, amount) when is_binary(player) and is_integer(amount) do
    %__MODULE__{
      bets
      | stakes: Map.put(bets.stakes, player, amount)
    }
  end

  def bet(bets, player, {_value, stake} = bet) do
    if bets.stakes[player] > stake do
      new_wagers = [{player, bet} | bets.wagered]
      new_stakes = stake_bet(bets.stakes, player, stake)

      %__MODULE__{bets | wagered: new_wagers, stakes: new_stakes}
    else
      {:error, "cannot bet more than currently staked"}
    end
  end

  defp stake_bet(stakes, player, stake) do
    Map.update!(stakes, player, &(&1 - stake))
  end

  def pay_bets(bets, value) do
    new_stakes = pay_winners(bets.stakes, bets.wagered, value)
    %__MODULE__{bets | wagered: [], stakes: new_stakes}
  end

  defp pay_winners(stakes, wagered, winning_value) do
    stakes
    |> Enum.reduce(%{}, fn {player, current_stake}, new_stakes ->
      new_stake = current_stake + winning_amount(wagered, player, winning_value)
      Map.put(new_stakes, player, new_stake)
    end)
  end

  defp winning_amount(wagered, player, winning_value) do
    wagered
    |> Enum.map(fn {a_player, {value, amount}} ->
      case {a_player, value} do
        # Hardcoded odds for now
        {^player, ^winning_value} -> amount * 2
        _ -> 0
      end
    end)
    |> Enum.sum()
  end

  def cash_out(bets, player) do
    new_stakes = Map.delete(bets.stakes, player)
    new_wagers = Enum.reject(bets.wagered, fn {a_player, _bet} -> a_player == player end)
    %__MODULE__{bets | stakes: new_stakes, wagered: new_wagers}
  end

  def total_money(bets, player) do
    player_stake = bets.stakes[player]
    wager_total = total_wagers(bets, player)
    player_stake + wager_total
  end

  defp total_wagers(bets, player) do
    bets.wagered
    |> Enum.reject(fn {a_player, _bet} ->
      a_player != player
    end)
    |> Enum.map(fn {_player, {_, amount}} ->
      amount
    end)
    |> Enum.sum()
  end
end
