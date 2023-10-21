defmodule LivekitWeb.DemoLive do
  use LivekitWeb, :live_view
  import Livekit.{Dropdown, Modal}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, socket}
  end
end
