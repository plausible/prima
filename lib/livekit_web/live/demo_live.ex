defmodule LivekitWeb.DemoLive do
  use LivekitWeb, :live_view
  import Livekit.{Dropdown, Modal, Combobox}
  embed_templates "demo_live/*"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, form_modal_open?: false)}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("open-form-modal", _params, socket) do
    {:noreply, assign(socket, form_modal_open?: true)}
  end

  @impl true
  def handle_event("close-form-modal", _params, socket) do
    {:noreply, assign(socket, form_modal_open?: false)}
  end

  @impl true
  def handle_event("search", _params, socket) do
    {:reply, %{"results" => ["foo", "bar", "baz"]}, socket}
  end
end
