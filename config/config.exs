# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :phx_ws_cli,
  ecto_repos: [PhxWsCli.Repo]

# Configures the endpoint
config :phx_ws_cli, PhxWsCliWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Ti6u38sKlKctvjNU7huQv7FNrRBUi7On0hB8cuHUvjSVunzVmewadpTn00uaXY+2",
  render_errors: [view: PhxWsCliWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PhxWsCli.PubSub,
  live_view: [signing_salt: "VnAex1OZ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
