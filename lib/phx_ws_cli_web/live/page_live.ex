defmodule PhxWsCliWeb.PageLive do
  use Phoenix.LiveView,
    layout: {PhxWsCliWeb.LayoutView, "live.html"},
    container: {:div, class: "h-screen"}

  use PhxWsCliWeb, :view_helpers

  alias Phoenix.PubSub
  alias PhxWsCli.SocketCli
  alias Phoenix.Channels.GenSocketClient

  @impl true
  def mount(_params, _session, socket) do
    s_id = to_string(Enum.random(1..1000))

    PubSub.subscribe(PhxWsCli.PubSub, s_id)

    {:ok,
     assign(socket,
       s_id: s_id,
       url: "",
       connected: false,
       s_pid: nil,
       channels: MapSet.new(),
       connected_channels: MapSet.new(),
       events: []
     )}
  end

  @impl true
  def handle_event("connect", %{"s" => %{"url" => url}}, socket) do
    case SocketCli.start_link(url, socket.assigns.s_id) do
      {:ok, s_pid} -> {:noreply, assign(socket, s_pid: s_pid, url: url)}
      {:error, err} -> {:noreply, socket}
    end
  end

  def handle_event("disconnect", %{}, socket) do
    send(socket.assigns.s_pid, :disconnect)

    {:noreply, socket}
  end

  def handle_event("join", %{"s" => %{"channel" => channel, "join_params" => _payload}}, socket) do
    send(socket.assigns.s_pid, {:join, channel, %{}})

    socket = assign(socket, channels: MapSet.put(socket.assigns.channels, channel))

    {:noreply, socket}
  end

  def handle_event("join", %{"topic" => t}, socket) do
    send(socket.assigns.s_pid, {:join, t, %{}})

    {:noreply, socket}
  end

  def handle_event("delete", %{"topic" => t}, socket) do
    socket = assign(socket, channels: MapSet.delete(socket.assigns.channels, t))

    {:noreply, socket}
  end

  def handle_event("leave", %{"topic" => t}, socket) do
    send(socket.assigns.s_pid, {:leave, t})

    {:noreply, socket}
  end

  # From SocketCli

  def handle_info(:disconnected, socket) do
    socket =
      assign(socket,
        url: "",
        connected: false,
        s_pid: nil,
        channels: MapSet.new(),
        connected_channels: MapSet.new(),
        events: [:disconnected | socket.assigns.events]
      )

    {:noreply, socket}
  end

  def handle_info(:connected, socket) do
    socket =
      assign(socket,
        events: [:connected | socket.assigns.events],
        connected: true
      )

    {:noreply, socket}
  end

  def handle_info({:joined, topic, _payload} = e, socket) do
    socket =
      assign(socket,
        connected_channels: MapSet.put(socket.assigns.connected_channels, topic),
        events: [e | socket.assigns.events]
      )

    {:noreply, socket}
  end

  def handle_info({:channel_closed, topic, _payload} = e, socket) do
    socket =
      assign(socket,
        connected_channels: MapSet.delete(socket.assigns.connected_channels, topic),
        events: [e | socket.assigns.events]
      )

    {:noreply, socket}
  end

  def handle_info({:join_error, topic, payload} = e, socket) do
    socket = assign(socket, events: [e | socket.assigns.events])

    {:noreply, socket}
  end

  def handle_info({:message, topic, event, payload} = e, socket) do
    socket = assign(socket, events: [e | socket.assigns.events])

    {:noreply, socket}
  end

  def handle_info({:reply, _payload} = e, socket) do
    {:noreply, socket}
  end
end
