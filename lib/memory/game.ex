defmodule Memory.Game do

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
      correct: MapSet.new()
    }
  end

  def client_view(game) do
    s = calcScore(game)
    b = calcClientBoard(game, nil, nil)
    %{
      guessBoard: b,
      score: s,
    }
  end

  def client_preview(game, previewIndex, previewIndex2) do
    s = calcScore(game)
    b = calcClientBoard(game, previewIndex, previewIndex2)
    %{
      guessBoard: b,
      score: s,
    }
  end

  def guess(game, index1, index2) do
    b = game.board
    let1 = elem(Enum.fetch(b, index1), 1)
    let2 = elem(Enum.fetch(b, index2), 1)
    cond do
      index1 == index2 ->
        game
      let1 == let2 ->
        c = game.correct
        |> MapSet.put(index1)
        |> MapSet.put(index2)
        Map.put(game, :correct, c)
      true ->
        w = game.wrongs
        w = w + 1
        Map.put(game, :wrongs, w)
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
end