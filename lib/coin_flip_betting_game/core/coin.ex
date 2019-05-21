defmodule CoinFlipBettingGame.Core.Coin do
  defstruct value: nil

  def new() do
    struct!(__MODULE__, [value: nil])
  end

  def flip() do
    struct!(__MODULE__, [value: random_value()])
  end

  defp random_value() do
    Enum.random(coin_values())
  end

  defp coin_values() do
    ~w(heads tails)a
  end
end
