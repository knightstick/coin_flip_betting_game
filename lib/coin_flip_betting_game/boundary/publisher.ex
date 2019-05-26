defmodule CoinFlipBettingGame.Boundary.Publisher do
  use GenServer

  def start_link(subscribers) when is_list(subscribers) do
    GenServer.start(__MODULE__, subscribers, name: __MODULE__)
  end

  def init(subscribers) when is_list(subscribers) do
    MapSet.new(subscribers)
    {:ok, subscribers}
  end

  # Can we just use from instead?
  def handle_call({:subscribe, pid}, _from, subscribers) do
    new_subscribers = MapSet.put(subscribers, pid)
    {:reply, :ok, new_subscribers}
  end

  def handle_call({:unsubscribe, pid}, _from, subscribers) do
    remaining_subscribers = MapSet.delete(subscribers, pid)
    {:reply, :ok, remaining_subscribers}
  end

  def handle_call({:publish_event, event}, _from, subscribers) do
    Enum.each(subscribers, &send_event(&1, event))
    {:reply, :ok, subscribers}
  end

  defp send_event(pid, event) do
    send(pid, event)
  end

  def subscribe(publisher \\ __MODULE__, pid) when is_pid(pid) do
    GenServer.call(publisher, {:subscribe, pid})
  end

  def unsubscribe(publisher \\ __MODULE__, pid) when is_pid(pid) do
    GenServer.call(publisher, {:unsubscribe, pid})
  end

  def publish_event(publisher \\ __MODULE__, event) do
    GenServer.call(publisher, {:publish_event, event})
  end
end
