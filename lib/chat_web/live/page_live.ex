defmodule ChatWeb.PageLive do
  use ChatWeb, :live_view
  require Logger

  alias Chat.ChatSupervisor

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("random-room", _params, socket) do
    random_slug = MnemonicSlugs.generate_slug(1)
    Logger.info("Random Slug " <> random_slug)
    ChatSupervisor.start_room(random_slug)
    {:noreply, push_redirect(socket, to: "/" <> random_slug)}
  end

end
