defmodule CoinFlipBettingGame.Boundary.Publisher do
  use GenServer

  def child_spec(topic) do
    %{
      id: {__MODULE__, topic},
      start: {__MODULE__, :start_link, [{topic, []}]},
      restart: :temporary
    }
  end

  def start_link({topic, subscribers}) when is_list(subscribers) do
    GenServer.start_link(__MODULE__, {topic, subscribers}, name: via(topic))
  end

  def init({topic, subscribers}) when is_list(subscribers) do
    subscribers = MapSet.new(subscribers)
    {:ok, {topic, subscribers}}
  end

  # Can we just use from instead?
  def handle_call({:subscribe, pid}, _from, {table_name, subscribers}) do
    new_subscribers = MapSet.put(subscribers, pid)
    {:reply, :ok, {table_name, new_subscribers}}
  end

  def handle_call({:unsubscribe, pid}, _from, {table_name, subscribers}) do
    remaining_subscribers = MapSet.delete(subscribers, pid)
    {:reply, :ok, {table_name, remaining_subscribers}}
  end

  def handle_call({:publish_event, event}, _from, {_, subscribers} = state) do
    Enum.each(subscribers, &send_event(&1, event))
    {:reply, :ok, state}
  end

  defp send_event(pid, event) do
    send(pid, event)
  end

  def subscribe(topic, pid) when is_pid(pid) do
    GenServer.call(via(topic), {:subscribe, pid})
  end

  def unsubscribe(topic, pid) when is_pid(pid) do
    GenServer.call(via(topic), {:unsubscribe, pid})
  end

  def publish_event(topic, event) do
    GenServer.call(via(topic), {:publish_event, event})
  end

  defp via(name) do
    {
      :via,
      Registry,
      {CoinFlipBettingGame.Registry.Publisher, name}
    }
  end
end
