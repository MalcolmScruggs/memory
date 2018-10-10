defmodule Memory.Game do

  require Logger

  def new do
    b = ["A", "B", "C", "D", "E", "F", "G", "H"]
    b = b ++ b
    b = Enum.shuffle(b)
    g = Enum.map 1..16, fn _ ->
      false
    end
    %{
      board: b,
      guessBoard: g,
      wrongs: 0,
      correct: MapSet.new(),
      players: %{},
      lastTurn: true
    }
  end

  def new(players) do
    Logger.info("new players")
    players = Enum.map players, fn {name, info} ->
      {name, %{ default_player() | score: info.score || 0 }}
    end
    Map.put(new(), :players, Enum.into(players, %{}))
  end

  def default_player() do
    %{
      corrects: 0,
      wrongs: 0,
    }
  end

  def client_view(game, user) do
    s = calcScore(game)
    b = calcClientBoard(game, nil, nil)
    p = calcPlayers(game)
    %{
      guessBoard: b,
      score: s,
      players: p,
      lastTurn: game.lastTurn
    }
  end

  def client_preview(game, user, previewIndex, previewIndex2) do
    s = calcScore(game)
    b = calcClientBoard(game, previewIndex, previewIndex2)
    p = calcPlayers(game)
    %{
      guessBoard: b,
      score: s,
      players: p,
      lastTurn: game.lastTurn
    }
  end

  def guess(game, player, index1, index2) do
    if Map.get(game, :lastTurn, true) == player do
      game
    else
      b = game.board
      let1 = elem(Enum.fetch(b, index1), 1)
      let2 = elem(Enum.fetch(b, index2), 1)
      pinfo = Map.get(game.players, player, default_player())
      cond do
        index1 == index2 ->
          Map.update(game, :lastTurn, true, fn _ -> player end)
        let1 == let2 ->
          c = game.correct
          |> MapSet.put(index1)
          |> MapSet.put(index2)
          pc = pinfo.corrects + 1;
          pinfo = %{pinfo | :corrects => pc}
          Map.put(game, :correct, c)
          |> Map.update(:players, %{}, &(Map.put(&1, player, pinfo)))
          |> Map.update(:lastTurn, true, fn _ -> player end)
        true ->
          w = game.wrongs + 1;
          pw = pinfo.wrongs + 1;
          pinfo = %{pinfo | :wrongs => pw}
          Map.put(game, :wrongs, w)
          |> Map.update(:players, %{}, &(Map.put(&1, player, pinfo)))
          |> Map.update(:lastTurn, true, fn _ -> player end)
      end
    end
  end

  def calcClientBoard(game, i1, i2) do
    Enum.map 0..15, fn i ->
      cond do
        MapSet.member?(game.correct, i) -> elem(Enum.fetch(game.board, i), 1)
        i == i1 || i == i2 -> elem(Enum.fetch(game.board, i), 1)
        true -> false
      end
    end
  end

  def calcScore(game) do
    (MapSet.size(game.correct) * 10) - (game.wrongs * 2)
  end

  def calcPlayers(game) do
    Enum.map game.players, fn {pn, pi} ->
    %{name: pn, wrongs: pi.wrongs, corrects: pi.corrects}
    end
  end
end