defmodule Chat.ChatServer do
  use GenServer

  alias Chat.ChatRegistry

  require Logger

  @spec start_link(binary) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(room_id) do
    Logger.info("Starting link for #{room_id}")
    GenServer.start(__MODULE__, room_id, name: via_tuple(room_id))
  end

  @impl GenServer
  def init(room_id) do
    Logger.info("Creating chat room server for #{room_id}")
    Process.flag(:trap_exit, true)

    messages = Chat.StateHandoff.pickup(room_id)
    Logger.info("Messages picked from handoff genserver")
    Logger.info("#{inspect messages, charlists: :as_lists}")

    messages = if is_nil(messages) do
      []
    else
      messages
    end

    Logger.info("Pickup result from crdt #{inspect messages, charlists: :as_lists}")

    {:ok, %{room_id: room_id, messages: messages}}
  end

  @spec via_tuple(String.t()) :: {:via, Horde.Registry, {ChatRegistry, String.t()}}
  defp via_tuple(room_id) do
    {:via, Horde.Registry, {ChatRegistry, room_id}}
  end

  def get_room(room_id) do
    call_by_name(room_id, :get_room)
  end

  @spec add_messages(String.t(), List.t()) :: {:ok, List.t()}
  def add_messages(room_id, new_messages) do
    Logger.info("To room_id #{room_id} add #{inspect new_messages}")
    {:ok, messages} = call_by_name(room_id, {:add_messages, new_messages})
    {:ok, messages}
  end

  defp call_by_name(room_id, command) do
    case room_pid(room_id) do
      room_pid when is_pid(room_pid) ->
        GenServer.call(room_pid, command)

      nil ->
        {:error, :room_not_found}
    end
  end

  @impl GenServer
  def handle_call(:get_room, _from, state) do
    {:reply, {:ok, state.messages}, state}
  end

  @impl GenServer
  def handle_call({:add_messages, new_messages}, _from, state) do
    messages = state.messages ++ new_messages
    {:reply, {:ok, messages}, %{state | messages: messages}}
  end

  def room_pid(room_id) do
    room_pid = room_id
    |> via_tuple()
    |>  GenServer.whereis()

    if is_pid(room_pid) do
      room_pid
    else
      Logger.info("Chat room gen server not found! #{room_id}. Creating new")

      # messages = Chat.StateHandoff.pickup(room_id)
      # Logger.info("Pickup result from crdt #{inspect messages}")

      {:ok, pid} = Chat.ChatSupervisor.start_room(room_id)
      pid
    end

  end

  @impl GenServer
  def handle_info({:EXIT, _pid, reason}, state) do
    Logger.info(":EXIT received - Reason: #{inspect(reason)} and State: #{inspect(state)}")
    save_state(state)
    {:stop, reason, state}
  end

  @doc """
  When shutdown is issued, state is saved here for other nodes to utilize
  """
  @impl true
  def terminate(reason, _state) do
    Logger.warn("Horde dynamicsupervisor in #{Node.self()} has initiated shut down. Sleeping for handoff")
    # messages = Chat.StateHandoff.pickup(state.room_id)
    # Logger.info("Pickup result from crdt #{messages}")
    # Sleeping for handoff to complete
    Process.sleep(10_000)
    Logger.info("Sleep complete. Exiting.")
    Logger.info("Reason: #{inspect(reason)}")
  end

  def save_state(state) do
    room_id = state.room_id
    Chat.StateHandoff.handoff(room_id, state.messages)
    {:reply, :ok}
  end
end
