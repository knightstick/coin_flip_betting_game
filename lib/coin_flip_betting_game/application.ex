defmodule CoinFlipBettingGame.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Registry, [name: CoinFlipBettingGame.Registry.TableSession, keys: :unique]},
      {Registry, [name: CoinFlipBettingGame.Registry.Publisher, keys: :unique]},
      {DynamicSupervisor,
       [name: CoinFlipBettingGame.Supervisor.TableSession, strategy: :one_for_one]},
      {DynamicSupervisor,
       [name: CoinFlipBettingGame.Supervisor.Publisher, strategy: :one_for_one]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CoinFlipBettingGame.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
