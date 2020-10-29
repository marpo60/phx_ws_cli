defmodule PhxWsCliWeb.RoomChannel do
  use Phoenix.Channel

  require Logger

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def terminate(reason, _state) do
    Logger.warn("Terminated #{inspect(reason)}")
    :ok
  end
end
