defmodule LivekitWeb.DemoLive do
  use LivekitWeb, :live_view
  import Livekit.{Dropdown, Modal, Combobox}
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
      |> stream_configure(:suggestions, dom_id: &"suggestions-#{&1}")
      |> stream(:suggestions, [])

    {:ok, socket}
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
  def handle_event("async_combobox_search", params, socket) do
    input = get_in(params, params["_target"])

    suggestions =
      Enum.filter(@options, fn option ->
        String.contains?(String.downcase(option), String.downcase(input))
      end)

    {:noreply, stream(socket, :suggestions, suggestions, reset: true)}
  end

  @impl true
  def handle_event("save", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end
end
