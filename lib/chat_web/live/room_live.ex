defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view
  alias Chat.ChatServer

  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    username = MnemonicSlugs.generate_slug(2)

    {:ok, messages} = ChatServer.get_room(room_id)

    self_node = inspect node()
    connected_nodes = inspect Node.list()

    if connected?(socket) do
      ChatWeb.Endpoint.subscribe(topic)
      ChatWeb.Presence.track(self(), topic, username, %{})
    end

    {:ok, assign(socket,
      room_id: room_id,
      topic: topic,
      username: username,
      message: "",
      messages: messages,
      user_list: [],
      temporary_assigns: [messages: []],
      node: self_node,
      connected_nodes: connected_nodes
    )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)
    message = %{uuid: UUID.uuid4(), username: socket.assigns.username, content: message}
    ChatServer.add_messages(socket.assigns.room_id, [message])
    ChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("form_updated", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    self_node = inspect node()
    connected_nodes = inspect Node.list()

    {:noreply, assign(socket,
        messages: [message],
        node: self_node,
        connected_nodes: connected_nodes
    )}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}, topic: topic}, socket) do
    Logger.info(joins: joins, leaves: leaves, topic: topic)
    # join_messages = joins
    # |> Map.keys()
    # |> Enum.map(fn username -> %{uuid: UUID.uuid4(), content: "#{username} joined", type: :system} end)

    # leave_messages = leaves
    # |> Map.keys()
    # |> Enum.map(fn username -> %{uuid: UUID.uuid4(), content: "#{username} left", type: :system} end)

    user_list = ChatWeb.Presence.list(socket.assigns.topic)
    |> Map.keys()
    Logger.info(user_list: user_list)

    # ChatServer.add_messages(socket.assigns.room_id, join_messages ++ leave_messages)

    # Removing joining/left messages out for now.
    {:noreply, assign(socket, user_list: user_list)}
  end

  @spec display_message(%{:content => any, :uuid => any, optional(any) => any}) :: {:safe, [...]}
  def display_message(%{type: :system, uuid: uuid, content: content}) do
    ~E"""
    <p id="<%=uuid%>"><i><%=content%></i></p>
    """
  end

  def display_message(%{uuid: uuid, content: content, username: username}) do
    ~E"""
    <p id="<%=uuid%>"><strong><%=username%></strong>:<span><%=content%></span></p>
    """
  end
end
