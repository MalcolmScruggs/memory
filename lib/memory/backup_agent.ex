defmodule Memory.BackupAgent do
  use Agent

  #This code comes from the lecture notes
  #http://www.ccs.neu.edu/home/ntuck/courses/2018/09/cs4550/notes/07-state/notes.html
  # TODO: Add timestamps and expiration.

  def start_link(_args) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(name, val) do
    Agent.update __MODULE__, fn state ->
      Map.put(state, name, val)
    end
  end

  def get(name) do
    Agent.get __MODULE__, fn state ->
      Map.get(state, name)
    end
  end
end