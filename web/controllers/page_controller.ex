defmodule Gardener.PageController do
  use Gardener.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
