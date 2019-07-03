defmodule CoinFlipBettingGameInterfaceWeb.TableSessionView do
  use CoinFlipBettingGameInterfaceWeb, :view

  def table_name(table), do: table.name

  def coin_value(%{coin: %{value: nil}}), do: "Not flipped yet"
  def coin_value(%{coin: %{value: value}}), do: value |> to_string() |> String.capitalize()
end
