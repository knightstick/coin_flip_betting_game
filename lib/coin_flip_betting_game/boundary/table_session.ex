defmodule CoinFlipBettingGame.Boundary.TableSession do
  use GenServer

  alias CoinFlipBettingGame.Core.{Publisher, Table}

  defmodule State do
    defstruct table: nil, subscribers: []
  end

  def child_spec(table) do
    %{
      id: {__MODULE__, table.name},
      start: {__MODULE__, :start_link, [table]},
      restart: :temporary
    }
  end

  def start_link(table) do
    GenServer.start(__MODULE__, table, name: via(table.name))
  end

  def init(table) do
    {:ok, %State{table: table}}
  end

  def handle_call(
        {:join_table, player},
        _from,
        %State{table: table, subscribers: subscribers} = state
      ) do
    %Table{} = table = Table.join(table, player, default_stake())
    Publisher.publish_event(subscribers, {:player_joined, {table.name, player, default_stake()}})
    {:reply, table, %State{state | table: table}}
  end

  def handle_call(
        {:bet, player, {_, _} = bet},
        _from,
        %State{table: table, subscribers: subscribers} = state
      ) do
    case Table.bet(table, player, bet) do
      %Table{} = table ->
        Publisher.publish_event(subscribers, {:bet_placed, {table.name, player, bet}})
        {:reply, table.bets, %State{state | table: table}}

      error ->
        {:reply, error, state}
    end
  end

  def handle_call(:flip_and_pay, _from, %State{table: table, subscribers: subscribers} = state) do
    %Table{} = table = Table.flip_and_pay(table)
    Publisher.publish_event(subscribers, {:bets_paid, {table.name, table.bets}})
    {:reply, table, %State{state | table: table}}
  end

  def handle_call(
        {:cash_out, player},
        _from,
        %State{table: table, subscribers: subscribers} = state
      ) do
    returned_stake = Table.total_money(table, player)

    case Table.cash_out(table, player) do
      nil ->
        {:stop, :normal, returned_stake, nil}

      %Table{} = table ->
        Publisher.publish_event(subscribers, {:player_left, {table.name, player}})
        {:reply, returned_stake, %State{state | table: table}}
    end
  end

  def handle_call(
        {:subscribe_to_table_events, pid},
        _from,
        %State{subscribers: subscribers} = state
      ) do
    new_subs = [pid | subscribers] |> IO.inspect()
    {:reply, :ok, %State{state | subscribers: new_subs}}
  end

  def join_or_create(table_name, player) do
    with nil <- current_session(table_name) do
      create_table(table_name)
    end

    join_table(table_name, player)
  end

  defp create_table(table_name) do
    table = Table.new(table_name)

    DynamicSupervisor.start_child(
      CoinFlipBettingGame.Supervisor.TableSession,
      {__MODULE__, table}
    )
  end

  def join_table(name, player) do
    GenServer.call(via(name), {:join_table, player})
  end

  def bet(name, player, {_, _} = bet) do
    GenServer.call(via(name), {:bet, player, bet})
  end

  def flip_and_pay(name) do
    GenServer.call(via(name), :flip_and_pay)
  end

  def cash_out(name, player) do
    GenServer.call(via(name), {:cash_out, player})
  end

  def subscribe_to_table_events(name, pid) do
    GenServer.call(via(name), {:subscribe_to_table_events, pid})
  end

  defp default_stake() do
    1000
  end

  defp current_session(table_name) do
    GenServer.whereis(via(table_name))
  end

  defp via(name) do
    {
      :via,
      Registry,
      {CoinFlipBettingGame.Registry.TableSession, name}
    }
  end
end
