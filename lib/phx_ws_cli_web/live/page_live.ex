defmodule PhxWsCliWeb.PageLive do
  use PhxWsCliWeb, :live_view

  alias Phoenix.PubSub
  alias PhxWsCli.SocketCli
  alias Phoenix.Channels.GenSocketClient

  @impl true
  def mount(_params, _session, socket) do
    s_id = to_string(Enum.random(1..1000))

    PubSub.subscribe(PhxWsCli.PubSub, s_id)

    {:ok, assign(socket, s_id: s_id, url: "", connected: false, t_pid: nil, channel: "", join_params: "")}
  end

  @impl true
  def handle_event("connect", %{"url" => url}, socket) do
    case SocketCli.start_link(url, socket.assigns.s_id) do
      {:ok, t_pid} -> {:noreply, assign(socket, t_pid: t_pid, url: url)}
      {:error, _err} -> {:noreply, socket}
    end
  end

  def handle_event("disconnect", %{}, socket) do
    send(socket.assigns.t_pid, :disconnect)

    {:noreply, socket}
  end

  def handle_event("join", %{"channel" => channel, "join_params" => payload}, socket) do
    payload = parse_payload(payload)
    send(socket.assigns.t_pid, {:join, channel, payload})

    {:noreply, socket}
  end

  # From SocketCli

  def handle_info(:disconnected, socket) do
    socket = socket
             |> assign(connected: false)

    {:noreply, socket}
  end

  def handle_info(:connected, socket) do
    socket = socket
             |> assign(connected: true)

    {:noreply, socket}
  end

  def handle_info({:joined, _payload}, socket) do
    {:noreply, socket}
  end

  def parse_payload(str) do
    case Jason.decode(str) do
      {:ok, payload} -> payload
      {:error, _} -> %{}
    end
  end
end
