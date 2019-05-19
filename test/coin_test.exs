defmodule CoinTest do
  use ExUnit.Case

  alias CoinFlipBettingGame.Core.Coin

  describe "flip" do
    test "picks either heads or tails" do
      %Coin{value: value} = Coin.flip()

      assert value in [:heads, :tails]
    end

    test "picks both values randomly" do
      first = Coin.flip().value
      assert eventually_different(first)
    end

    defp eventually_different(first_value) do
      Stream.repeatedly(fn -> Coin.flip().value end)
      |> Enum.find(fn value -> value != first_value end)
    end
  end
end
