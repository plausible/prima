defmodule PrimaWeb.FixturesLive do
  @moduledoc false
  use PrimaWeb, :live_view
  import Prima.{Dropdown, Modal, Combobox}
  embed_templates "fixtures_live/*"

  @options [
    "Cherry",
    "Kiwi",
    "Grapefruit",
    "Orange",
    "Banana"
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(async_modal_open?: false)
      |> assign(selected_fruit: nil)
      |> stream_configure(:suggestions, dom_id: &"suggestions-#{&1}")
      |> stream(:suggestions, [])

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"live_action" => live_action}, _uri, socket) do
    {:noreply, assign(socket, live_action: live_action)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("open-async-modal", _params, socket) do
    Process.send_after(self(), :show_async_modal, 1000)
    {:noreply, assign(socket, async_modal_open?: false)}
  end

  @impl true
  def handle_event("close-async-modal", _params, socket) do
    {:noreply, assign(socket, async_modal_open?: false)}
  end

  @impl true
  def handle_event("async_combobox_search", params, socket) do
    input = get_in(params, params["_target"])

    suggestions =
      Enum.filter(@options, fn option ->
        String.contains?(String.downcase(option), String.downcase(input))
      end)

    {:noreply, stream(socket, :suggestions, suggestions, reset: true)}
  end

  @impl true
  def handle_event("selection_changed", %{"fruit" => fruit}, socket) do
    {:noreply, assign(socket, selected_fruit: fruit)}
  end

  @impl true
  def handle_info(:show_async_modal, socket) do
    {:noreply, assign(socket, async_modal_open?: true)}
  end

  defp custom_title_component(assigns) do
    ~H"""
    <span class="custom-title" data-prima-ref={assigns[:"data-prima-ref"]} id={assigns[:id]}>
      {render_slot(assigns.inner_block)}
    </span>
    """
  end
end
