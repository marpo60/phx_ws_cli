defmodule PhxWsCli.SocketCli do
  alias Phoenix.Channels.GenSocketClient
  alias Phoenix.PubSub

  require Logger

  @behaviour GenSocketClient

  def start_link(url, id) do
    GenSocketClient.start_link(
      __MODULE__,
      Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
      [url, id]
    )
  end

  def init([url, id]) do
    {:connect, url, [], %{id: id}}
  end

  def handle_connected(transport, state) do
    PubSub.broadcast(PhxWsCli.PubSub, state.id, :connected)
    {:ok, state}
  end

  def handle_disconnected(reason, state) do
    PubSub.broadcast(PhxWsCli.PubSub, state.id, :disconnected)
    {:ok, state}
  end

  def handle_joined(topic, payload, _transport, state) do
    PubSub.broadcast(PhxWsCli.PubSub, state.id, {:joined, payload})

    {:ok, state}
  end

  def handle_join_error(topic, payload, _transport, state) do
    Logger.error("join error on the topic #{topic}: #{inspect payload}")
    {:ok, state}
  end

  def handle_channel_closed(topic, payload, _transport, state) do
    Logger.error("disconnected from the topic #{topic}: #{inspect payload}")
    Process.send_after(self(), {:join, topic}, :timer.seconds(1))
    {:ok, state}
  end

  def handle_message(topic, event, payload, _transport, state) do
    Logger.warn("message on topic #{topic}: #{event} #{inspect payload}")
    {:ok, state}
  end

  def handle_reply("ping", _ref, %{"status" => "ok"} = payload, _transport, state) do
    Logger.info("server pong ##{payload["response"]["ping_ref"]}")
    {:ok, state}
  end

  def handle_reply(topic, _ref, payload, _transport, state) do
    Logger.warn("reply on topic #{topic}: #{inspect payload}")
    {:ok, state}
  end

  def handle_info(:connect, _transport, state) do
    Logger.info("connecting")
    {:connect, state}
  end

  def handle_info({:join, topic, payload}, transport, state) do
    GenSocketClient.join(transport, topic, payload)

    {:ok, state}
  end

  def handle_info(:disconnect, _transport, state) do
    {:stop, "stop", state}
  end

  def handle_info(message, _transport, state) do
    Logger.warn("Unhandled message #{inspect message}")
    {:ok, state}
  end

  def handle_call(_message, _arg2, _transport, state) do
    {:noreply, state}
  end
end
