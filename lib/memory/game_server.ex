defmodule Memory.GameServer do
  use GenServer

  alias Memory.Game
  require Logger

  ##Interface
  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def join(game, user) do
    Logger.debug "Join"
    GenServer.call(__MODULE__, {:join, game, user})
  end

  def view(game, user) do
    GenServer.call(__MODULE__, {:view, game, user})
  end

  def guess(game, user, index1, index2) do
    GenServer.call(__MODULE__, {:guess, game, user, index1, index2})
  end

  def preview(game, user, index1) do
    GenServer.call(__MODULE__, {:preview, game, user, index1})
  end

  def restart(game, user) do
    GenServer.call(__MODULE__, {:restart, game, user})
  end


  ##Implementations
  def init(state) do
    {:ok, state}
  end

  def handle_call({:join, game, user}, _from, state) do
    g = Map.get(state, game, Game.new)
    |> Game.join(user)
    v = Game.client_view(g, user)
    MemoryWeb.Endpoint.broadcast("games:#{game}", "new:msg", %{"game" => v, "action" => "join"})
    {:reply, v, Map.put(state, game, g)}
  end

  def handle_call({:view, game, user}, _from, state) do
    g = Map.get(state, game, Game.new)
    {:reply, Game.client_view(g, user), Map.put(state, game, g)}
  end

  def handle_call({:guess, game, user, index1, index2}, _from, state) do
    g = Map.get(state, game, Game.new)
    |> Game.guess(user, index1, index2)
    if g != false do
      v = Game.client_preview(g, user, index1, index2)
      MemoryWeb.Endpoint.broadcast("games:#{game}", "new:msg", %{"game" => v, "action" => "guess"})
      {:reply, v, Map.put(state, game, g)}
    else
      {:reply, Game.client_view(Map.get(state, game, Game.new), user), state}
    end
  end

  def handle_call({:preview, game, user, index1}, _from, state) do
    g = Map.get(state, game, Game.new)
    v = Game.guess_preview(g, user, index1)
    if v != false do
      MemoryWeb.Endpoint.broadcast("games:#{game}", "new:msg", %{"game" => v, "action" => "preview"})
      {:reply, v, Map.put(state, game, g)}
    else
      {:reply, Game.client_view(Map.get(state, game, Game.new), user), state}
    end
  end

  def handle_call({:restart, game, user}, _from, state) do
    g = Game.restart(game, user)
    v = Game.client_view(g, user)
    MemoryWeb.Endpoint.broadcast("games:#{game}", "new:msg", %{"game" => v, "action" => "restart"})
    {:reply, v, Map.put(state, game, g)}
  end
end