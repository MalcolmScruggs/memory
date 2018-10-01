defmodule Memory.Game do

  require Logger

  def new do
    b = ["A", "B", "C", "D", "E", "F", "G", "H"]
    b = b ++ b
    b = Enum.shuffle(b)
    g = Enum.map 1..16, fn _ ->
      false
    end
    Logger.error "HERE IN NEWWW"
    Logger.error is_list(b)
    Logger.error elem(Enum.fetch(b, 0), 1)
    %{
      board: b,
      guessBoard: g,
      wrongs: 0,
      correct: MapSet.new()
    }
  end

  def client_view(game) do
    s = (MapSet.size(game.correct) * 10) - (game.wrongs * 2) #todo refactoring into methods
    b = Enum.map 0..15, fn i ->
      cond do
        MapSet.member?(game.correct, i) -> elem(Enum.fetch(game.board, i), 1)
        true -> false
      end
    end
    %{
      guessBoard: b,
      score: s,
      actual: game.board
    }
  end

  def client_preview(game, previewIndex) do
    s = (MapSet.size(game.correct) * 10) - (game.wrongs * 2)
    b = Enum.map 0..15, fn i ->
      cond do
        MapSet.member?(game.correct, i) -> elem(Enum.fetch(game.board, i), 1)
        i == previewIndex -> elem(Enum.fetch(game.board, i), 1)
        true -> false
      end
    end
    %{
      guessBoard: b,
      score: s,
      actual: game.board
    }
  end

  def client_preview(game, previewIndex, previewIndex2) do
    s = (MapSet.size(game.correct) * 10) - (game.wrongs * 2)
    b = Enum.map 0..15, fn i ->
      cond do
        MapSet.member?(game.correct, i) -> elem(Enum.fetch(game.board, i), 1)
        i == previewIndex || i == previewIndex2 -> elem(Enum.fetch(game.board, i), 1)
        true -> false
      end
    end
    %{
      guessBoard: b,
      score: s,
      actual: game.board
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
end