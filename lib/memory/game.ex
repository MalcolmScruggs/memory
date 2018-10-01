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
      wrongs: 0
    }
  end

  def client_view(game) do
#    %{
#      board: game.guessBoard,
#      score: game.wrongs
#    }
    game
  end

  def guess(game, index1, index2) do
    b = game.board
    let1 = elem(Enum.fetch(b, index1), 1)
    let2 = elem(Enum.fetch(b, index2), 1)
    cond do
      index1 == index2 ->
        game
      Enum.fetch(b, index1) == Enum.fetch(b, index2) ->
        g = game.guessBoard
        g = List.replace_at(g, index1, let1)
        g = List.replace_at(g, index2, let2)
        Map.put(game, :guessBoard, g)
      true ->
        w = game.wrongs
        w = w + 1
        Map.put(game, :wrongs, w)
    end
  end
end