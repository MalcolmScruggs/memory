defmodule Memory.Game do

  require Logger

  def new do
    b = ["A", "B", "C", "D", "E", "F", "G", "H"]
    b = b ++ b
    b = Enum.shuffle(b)
    %{
      board: b,
      wrongs: 0,
      correct: MapSet.new(),
      players: %{},
      lastTurn: true
    }
  end

  def restart(game, player) do
    if !Map.has_key?(game.players, player) do
      new()
    else
      game
    end
  end

  def join(game, user) do
    if (map_size(game.players) < 2 && !Map.has_key?(game.players, user)) do
      Map.update(game, :players, %{}, &(Map.put(&1, user, default_player())))
    else
      game
    end
  end

  def default_player() do
    %{
      corrects: 0,
      wrongs: 0,
    }
  end

  def client_view(game, user) do
    client_preview(game, user, nil, nil)
  end

  def client_preview(game, user, previewIndex, previewIndex2) do
    %{
      guessBoard: calcClientBoard(game, previewIndex, previewIndex2),
      score: calcScore(game),
      players: calcPlayers(game),
      nextTurn: calcNextTurn(game),
      winner: calcWinner(game)
    }
  end

  def guess_preview(game, player, previewIndex) do
    if !Map.has_key?(game.players, player) || Map.get(game, :lastTurn, true) == player do
      false
    else
      client_preview(game, player, previewIndex, nil)
    end
  end


  def guess(game, player, index1, index2) do
    if !Map.has_key?(game.players, player) || Map.get(game, :lastTurn, true) == player do
      false
    else
      b = game.board
      let1 = elem(Enum.fetch(b, index1), 1)
      let2 = elem(Enum.fetch(b, index2), 1)
      pinfo = Map.get(game.players, player, default_player())
      cond do
        index1 == index2 || MapSet.size(game.correct) == 16 ->
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
      %{name: pn, corrects: pi.corrects}
    end
  end

  def calcWinner(game) do
    if MapSet.size(game.correct) == 16 do
      p = Enum.map game.players, fn {pn, pi} ->
        %{name: pn, corrects: pi.corrects}
      end
      winner = Enum.max_by(p, fn x -> Map.get(x, :corrects, -1) end)
      if (winner.corrects == 4) do
        %{name: "Tie Game!", corrects: 4}
      else
        winner
      end
    else
      nil
    end
  end

  def calcNextTurn(game) do
    k = Map.keys(game.players)
    k = List.delete(k, game.lastTurn)
    if (length(k) > 0) do
       List.first(k)
    end
  end
end