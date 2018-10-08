defmodule MemoryWeb.Plugs.PutUserToken do
  # Code taken from lecture notes
  # http://www.ccs.neu.edu/home/ntuck/courses/2018/09/cs4550/notes/09-two-players/notes.html
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if user = get_session(conn, :user) do
      token = Phoenix.Token.sign(conn, "user socket", user)
      assign(conn, :user_token, token)
    else
      assign(conn, :user_token, "")
    end
  end
end