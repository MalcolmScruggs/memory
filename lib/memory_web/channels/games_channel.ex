defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.GameServer

  def join("games:" <> game, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :game, game)
      view = GameServer.view(game, socket.assigns[:user])
      {:ok, %{"join" => game, "game" => view}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("guess", %{"index1" => i1, "index2" => i2 }, socket) do
    view = GameServer.guess(socket.assigns[:game], socket.assigns[:user], i1, i2)
    {:reply, {:ok, %{ "game" => view}}, socket}
  end

  def handle_in("preview", %{"index1" => i1 }, socket) do
    view = GameServer.preview(socket.assigns[:game], socket.assigns[:user], i1)
    {:reply, {:ok, %{ "game" => view}}, socket}
  end

  def handle_in("restart", _payload, socket) do
    view = GameServer.restart(socket.assigns[:game], socket.assigns[:user])
    {:reply, {:ok, %{ "game" => view}}, socket}
  end

  def handle_in("getView", _payload, socket) do
    view = GameServer.view(socket.assigns[:game], socket.assigns[:user])
    {:reply, {:ok, %{ "game" => view}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
