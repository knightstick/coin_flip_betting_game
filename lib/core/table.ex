defmodule CoinFlipBettingGame.Core.Table do
  alias CoinFlipBettingGame.Core.{Coin, Bets}

  defstruct coin: nil, players: [], bets: nil

  def new() do
    %__MODULE__{coin: Coin.flip(), bets: Bets.new()}
  end

  def join(table, player, stake) when is_binary(player) do
    %__MODULE__{
      table
      | players: [player | table.players],
        bets: Bets.join(table.bets, player, stake)
    }
  end

  def bet(table, player, {_, _} = bet) do
    %__MODULE__{table | bets: Bets.bet(table.bets, player, bet)}
  end

  def flip_and_pay(table) do
    new_coin = %Coin{value: winning_value} = Coin.flip()

    %__MODULE__{
      table
      | bets: Bets.pay_bets(table.bets, winning_value),
        coin: new_coin
    }
  end
end
