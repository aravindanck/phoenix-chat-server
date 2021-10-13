defmodule Chat.ChatSupervisor do
  @moduledoc """
  Dynamically starts a Chat Room Server
  """

  use Horde.DynamicSupervisor

  alias Chat.ChatServer

  require Logger

  def start_link(init_arg) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, [name: __MODULE__, shutdown: 30_000])
  end

  def init(init_arg) do
    [strategy: :one_for_one, members: members()]
      |> Keyword.merge(init_arg)
      |> Horde.DynamicSupervisor.init()

  end

  defp members() do
    []
  end

  def start_room(room_id) do
    child_spec = %{
      id: room_id,
      start: {ChatServer, :start_link, [room_id]}
    }

    Logger.info("Starting Chat Room with room_id #{room_id}")

    Horde.DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @spec stop_room(String.t()) :: :ok
  def stop_room(room_id) do
    case ChatServer.room_pid(room_id) do
      pid when is_pid(pid) ->
        Horde.DynamicSupervisor.terminate_child(__MODULE__, pid)
      nil ->
        :ok
    end
  end

  def which_children do
    Supervisor.which_children(__MODULE__)
  end
end
