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
    PubSub.broadcast(PhxWsCli.PubSub, state.id, {:joined, topic, payload})

    {:ok, state}
  end

  def handle_join_error(topic, payload, _transport, state) do
    PubSub.broadcast(PhxWsCli.PubSub, state.id, {:join_error, topic, payload})
    {:ok, state}
  end

  def handle_channel_closed(topic, payload, _transport, state) do
    PubSub.broadcast(PhxWsCli.PubSub, state.id, {:channel_closed, topic, payload})
    {:ok, state}
  end

  def handle_message(topic, event, payload, _transport, state) do
    PubSub.broadcast(PhxWsCli.PubSub, state.id, {:message, topic, event, payload})

    {:ok, state}
  end

  def handle_reply(topic, _ref, payload, _transport, state) do
    PubSub.broadcast(PhxWsCli.PubSub, state.id, {:reply, payload})

    {:ok, state}
  end

  def handle_call(message, _arg2, _transport, state) do
    Logger.warn("Unhandled #handle_call #{inspect(message)}")

    {:noreply, state}
  end

  def handle_info({:join, topic, payload}, transport, state) do
    GenSocketClient.join(transport, topic, payload)

    {:ok, state}
  end

  def handle_info({:leave, topic}, transport, state) do
    GenSocketClient.leave(transport, topic)

    {:ok, state}
  end

  def handle_info(:disconnect, transport, state) do
    GenServer.stop(transport.transport_pid)

    {:ok, state}
  end

  def handle_info(message, _transport, state) do
    Logger.warn("Unhandled #handle_info #{inspect(message)}")

    {:ok, state}
  end
end
