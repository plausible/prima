defmodule DemoWeb.FixturesLive do
  @moduledoc false
  use DemoWeb, :live_view
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
      |> assign(form_change_count: 0)
      |> assign(trigger_label: "Open Dropdown")
      |> assign(modal_title: "Good news")
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
  def handle_event("form_changed", %{"fruit" => fruit}, socket) do
    # Treat empty string as nil for display purposes
    selected_fruit = if fruit == "", do: nil, else: fruit

    socket =
      socket
      |> update(:form_change_count, &(&1 + 1))
      |> assign(selected_fruit: selected_fruit)

    {:noreply, socket}
  end

  @impl true
  def handle_event("update-dropdown-trigger", _params, socket) do
    {:noreply, assign(socket, trigger_label: "Updated Trigger")}
  end

  @impl true
  def handle_event("update-modal-title", _params, socket) do
    {:noreply, assign(socket, modal_title: "Updated Title")}
  end

  def handle_event("close-frontend-modal", _params, socket) do
    {:noreply, push_event(socket, "prima:modal:close", %{})}
  end

  @impl true
  def handle_event("open-frontend-modal", _params, socket) do
    {:noreply, push_event(socket, "prima:modal:open", %{})}
  end

  @impl true
  def handle_event("close-specific-modal", %{"id" => id}, socket) do
    {:noreply, push_event(socket, "prima:modal:close", %{id: id})}
  end

  @impl true
  def handle_event("open-specific-modal", %{"id" => id}, socket) do
    {:noreply, push_event(socket, "prima:modal:open", %{id: id})}
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

  attr :rest, :global
  slot :inner_block, required: true

  defp custom_button(assigns) do
    ~H"""
    <button type="button" {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end
end
