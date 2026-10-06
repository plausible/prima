defmodule DemoWeb.FixturesLive do
  @moduledoc false
  use DemoWeb, :live_view
  import Prima.{Dropdown, Modal, Combobox, Listbox}
  embed_templates "fixtures_live/*"

  @options [
    "Cherry",
    "Kiwi",
    "Grapefruit",
    "Orange",
    "Banana"
  ]

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(async_modal_open?: false)
      |> assign(selected_fruit: nil)
      |> assign(form_change_count: 0)
      |> assign(submission_multiple: params["multiple"] == "true")
      |> assign(
        submission_selection:
          if(params["selection"], do: Jason.decode!(params["selection"], keys: :atoms!))
      )
      |> assign(submission_change: %{})
      |> assign(listbox_disabled?: false, submitted_fruit: "not submitted")
      |> assign(trigger_label: "Open Dropdown")
      |> assign(modal_title: "Good news")
      |> assign(modal_initial_show?: params["show"] == "true")
      |> assign(modal_present?: true)
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
  def handle_event("async_combobox_search", %{"query" => input}, socket) do
    suggestions =
      Enum.filter(@options, fn option ->
        String.contains?(String.downcase(option), String.downcase(input))
      end)

    {:noreply, stream(socket, :suggestions, suggestions, reset: true)}
  end

  @impl true
  def handle_event("form_changed", params, socket) do
    fruit = params["fruit"]
    # Treat empty string as nil for display purposes
    selected_fruit = if fruit == "", do: nil, else: fruit

    socket =
      socket
      |> update(:form_change_count, &(&1 + 1))
      |> assign(selected_fruit: selected_fruit)

    {:noreply, socket}
  end

  @impl true
  def handle_event("submission_changed", params, socket) do
    selection =
      for value <- List.wrap(params["fruits"] || params["fruit"]) do
        Enum.find(List.wrap(socket.assigns.submission_selection), &(to_string(&1.value) == value)) ||
          %{value: value}
      end

    selection = if socket.assigns.submission_multiple, do: selection, else: List.first(selection)

    {:noreply,
     socket
     |> assign(submission_change: params)
     |> assign(submission_selection: selection)
     |> update(:form_change_count, &(&1 + 1))}
  end

  @impl true
  def handle_event("toggle-listbox-disabled", _params, socket) do
    {:noreply, update(socket, :listbox_disabled?, &(!&1))}
  end

  @impl true
  def handle_event("listbox_form_submitted", params, socket) do
    {:noreply, assign(socket, submitted_fruit: Map.get(params, "fruit", "omitted"))}
  end

  @impl true
  def handle_event("update-dropdown-trigger", _params, socket) do
    {:noreply, assign(socket, trigger_label: "Updated Trigger")}
  end

  @impl true
  def handle_event("update-modal-title", _params, socket) do
    {:noreply, assign(socket, modal_title: "Updated Title")}
  end

  @impl true
  def handle_event("remove-modal", _params, socket) do
    {:noreply, assign(socket, modal_present?: false)}
  end

  def handle_event("close-frontend-modal", _params, socket) do
    {:noreply, Prima.Modal.push_close(socket)}
  end

  @impl true
  def handle_event("open-frontend-modal", _params, socket) do
    {:noreply, Prima.Modal.push_open(socket)}
  end

  @impl true
  def handle_event("close-specific-modal", %{"id" => id}, socket) do
    {:noreply, Prima.Modal.push_close(socket, id)}
  end

  @impl true
  def handle_event("open-specific-modal", %{"id" => id}, socket) do
    {:noreply, Prima.Modal.push_open(socket, id)}
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
