defmodule CoinFlipBettingGameEngine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Registry, [name: CoinFlipBettingGameEngine.Registry.TableSession, keys: :unique]},
      {Registry, [name: CoinFlipBettingGameEngine.Registry.Publisher, keys: :unique]},
      {DynamicSupervisor,
       [name: CoinFlipBettingGameEngine.Supervisor.TableSession, strategy: :one_for_one]},
      {DynamicSupervisor,
       [name: CoinFlipBettingGameEngine.Supervisor.Publisher, strategy: :one_for_one]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CoinFlipBettingGameEngine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
