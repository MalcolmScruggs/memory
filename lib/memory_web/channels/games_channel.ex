defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.Game

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = Game.new()
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("guess", %{"index1" => i1, "index2" => i2 }, socket) do
    game = Game.guess(socket.assigns[:game], i1, i2)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Game.client_preview(game, i1, i2)}}, socket}
    #todo figure out how to do deplays not with client_preview
  end

  def handle_in("preview", %{"index1" => i1 }, socket) do
    game = socket.assigns[:game]
    {:reply, {:ok, %{ "game" => Game.client_preview(game, i1)}}, socket}
  end

  def handle_in("restart", socket) do
    game = Game.new()
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
