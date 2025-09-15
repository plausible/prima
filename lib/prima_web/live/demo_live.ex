defmodule PrimaWeb.DemoLive do
  @moduledoc false
  use PrimaWeb, :live_view
  import Prima.{Dropdown, Modal, Combobox}
  embed_templates "demo_live/*"

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
      |> assign(form_modal_open?: false)
      |> assign(async_modal_open?: false)
      |> assign(submitted_form_data: nil)
      |> stream_configure(:suggestions, dom_id: &"suggestions-#{&1}")
      |> stream(:suggestions, [])

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
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
  def handle_event("open-async-modal", _params, socket) do
    {:noreply, assign(socket, async_modal_open?: true)}
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
  def handle_info(:close_form_modal, socket) do
    {:noreply, assign(socket, form_modal_open?: false)}
  end

  @impl true
  def handle_info({:form_submitted, form_data}, socket) do
    socket =
      socket
      |> assign(submitted_form_data: form_data)
      |> assign(form_modal_open?: false)

    {:noreply, socket}
  end
end
