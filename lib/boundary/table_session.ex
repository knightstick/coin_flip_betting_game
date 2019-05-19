defmodule CoinFlipBettingGame.Boundary.TableSession do
  use GenServer

  alias CoinFlipBettingGame.Core.Table

  def child_spec(table) do
    %{
      id: {__MODULE__, table.name},
      start: {__MODULE__, :start_link, [table]},
      restart: :temporary
    }
  end

  def start_link(table) do
    GenServer.start(__MODULE__, table, [name: via(table.name)])
  end

  def init(table) do
    {:ok, table}
  end

  def handle_call({:join_table, player}, _from, table) do
    table = Table.join(table, player, default_stake())
    {:reply, table.bets.stakes, table}
  end

  def handle_call({:bet, player, {_, _} = bet}, _from, table) do
    table = Table.bet(table, player, bet)
    {:reply, table.bets, table}
  end

  def handle_call(:flip_and_pay, _from, table) do
    table = Table.flip_and_pay(table)
    {:reply, table.bets.stakes, table}
  end

  def handle_call({:cash_out, player}, _from, table) do
    returned_stake = Table.total_money(table, player)
    table = Table.cash_out(table, player)
    {:reply, returned_stake, table}
  end

  def join_or_create(table_name, player) do
    # TODO: join if already started
    table = Table.new(table_name)

    DynamicSupervisor.start_child(
      CoinFlipBettingGame.Supervisor.TableSession,
      {__MODULE__, table}
    )

    join_table(table_name, player)
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

  defp default_stake() do
    1000
  end

  defp via(name) do
    {
      :via,
      Registry,
      {CoinFlipBettingGame.Registry.TableSession, name}
    }
  end
end
