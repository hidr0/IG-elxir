defmodule Ig.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    IO.puts("Hello, welcome to this .... IG scraper.")

    children = [
      Ig.Parser,
      Ig.Scraper
      # Starts a worker by calling: Ig.Worker.start_link(arg)
      # {Ig.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ig.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
