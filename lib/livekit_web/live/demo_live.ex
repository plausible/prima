defmodule LivekitWeb.DemoLive do
  use LivekitWeb, :live_view
  import Livekit.Dropdown

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, socket}
  end
end
