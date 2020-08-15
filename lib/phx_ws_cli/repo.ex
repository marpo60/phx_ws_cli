defmodule PhxWsCli.Repo do
  use Ecto.Repo,
    otp_app: :phx_ws_cli,
    adapter: Ecto.Adapters.Postgres
end
