defmodule PrimaWeb.DemoLive do
  @moduledoc false
  use PrimaWeb, :live_view
  import Prima.{Modal, Combobox}
  embed_templates "demo_live/*"

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(form_modal_open?: false)
      |> assign(submitted_form_data: nil)

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
