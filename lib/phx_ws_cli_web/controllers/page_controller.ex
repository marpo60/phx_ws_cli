defmodule PhxWsCliWeb.PageController do
  use PhxWsCliWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
