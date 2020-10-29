defmodule PhxWsCliWeb.EventComponent do
  use PhxWsCliWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, :event, assigns.event)}
  end

  def render(%{event: :connected} = assigns) do
    ~L"""
    <div class="border m-5 p-5">
      <div> Socket Connected </div>
    </div>
    """
  end

  def render(%{event: {:joined, topic, payload}} = assigns) do
    ~L"""
    <div class="border m-5 p-5">
      <div> Topic: <%= topic %> - Joined </div>
      <div>
        <%= inspect(payload) %>
      </div>
    </div>
    """
  end

  def render(%{event: {:join_error, topic, payload}} = assigns) do
    ~L"""
    <div class="border m-5 p-5">
      <div> Topic: <%= topic %> - Joined Failed </div>
      <div>
        <%= inspect(payload) %>
      </div>
    </div>
    """
  end

  def render(%{event: {:channel_closed, topic, payload}} = assigns) do
    ~L"""
    <div class="border m-5 p-5">
      <div> Topic: <%= topic %> - Closed </div>
      <div>
        <%= inspect(payload) %>
      </div>
    </div>
    """
  end

  def render(%{event: :disconnected} = assigns) do
    ~L"""
    <div class="border m-5 p-5">
      <div> Socket Disconnected </div>
    </div>
    """
  end

  def render(%{event: {:message, topic, event_name, payload}} = assigns) do
    ~L"""
    <div class="border m-5 p-5">
      <div> Topic: <%= topic %> - Name: <%= event_name %> - Incoming Message </div>
      <div>
        <%= inspect(payload) %>
      </div>
    </div>
    """
  end
end
