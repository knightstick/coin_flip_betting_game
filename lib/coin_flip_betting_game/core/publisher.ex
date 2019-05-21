defmodule CoinFlipBettingGame.Core.Publisher do
  def publish_event(subscribers, event) do
    Enum.each(subscribers, &send_event(&1, event))
  end

  def send_event(subscriber, event) do
    send(subscriber, event)
  end
end
