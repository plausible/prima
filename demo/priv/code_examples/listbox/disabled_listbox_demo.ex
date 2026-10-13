defmodule DemoWeb.DemoLive.DisabledListboxDemo do
  @moduledoc false
  use DemoWeb, :live_component
  import Prima.Listbox

  @impl true
  def mount(socket) do
    {:ok, assign(socket, disabled?: true, plan: nil, submitted: nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <form phx-change="plan_changed" phx-submit="submit" phx-target={@myself}>
      <div class="flex items-center gap-4">
        <.listbox id="disabled-listbox-example" name="plan" value={@plan} disabled={@disabled?}>
          <.listbox_trigger
            id="disabled-listbox-example-trigger"
            class="w-56 inline-flex justify-between items-center rounded-lg bg-white border border-gray-300 px-3 py-2 text-sm text-gray-700 hover:bg-gray-50 in-data-disabled:opacity-50 in-data-disabled:cursor-not-allowed in-data-disabled:hover:bg-white"
          >
            <.listbox_value>{@plan || "Select a plan..."}</.listbox_value>
            <svg
              class="h-5 w-5 text-gray-400"
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
            >
              <path
                fill-rule="evenodd"
                d="M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z"
                clip-rule="evenodd"
              />
            </svg>
          </.listbox_trigger>

          <.listbox_options
            id="disabled-listbox-example-options"
            class="min-w-[var(--reference-width)] py-1 rounded-md bg-white shadow-xs ring-1 ring-gray-300 focus:outline-none"
          >
            <.listbox_option
              id="disabled-listbox-example-option-basic"
              value="Basic"
              class="text-gray-700 data-focus:bg-gray-100 data-focus:text-gray-900 block w-full px-4 py-2 text-sm text-left"
            >
              Basic
            </.listbox_option>
            <.listbox_option
              id="disabled-listbox-example-option-pro"
              value="Pro"
              class="text-gray-700 data-focus:bg-gray-100 data-focus:text-gray-900 block w-full px-4 py-2 text-sm text-left"
            >
              Pro
            </.listbox_option>
          </.listbox_options>
        </.listbox>

        <button
          id="disabled-listbox-example-toggle"
          type="button"
          phx-click="toggle_disabled"
          phx-target={@myself}
          class="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
        >
          {if @disabled?, do: "Enable", else: "Disable"}
        </button>

        <button
          id="disabled-listbox-example-submit"
          type="submit"
          class="rounded-lg bg-gray-900 px-3 py-2 text-sm font-medium text-white hover:bg-gray-700"
        >
          Submit
        </button>
      </div>

      <p class="mt-4 text-sm text-gray-600">
        Submitted params:
        <span id="disabled-listbox-example-submitted" class="font-mono text-gray-900">
          {if @submitted, do: inspect(@submitted), else: "not submitted yet"}
        </span>
      </p>
    </form>
    """
  end

  @impl true
  def handle_event("plan_changed", %{"plan" => plan}, socket) do
    {:noreply, assign(socket, plan: plan)}
  end

  def handle_event("toggle_disabled", _params, socket) do
    {:noreply, update(socket, :disabled?, &(!&1))}
  end

  def handle_event("submit", params, socket) do
    {:noreply, assign(socket, submitted: params)}
  end
end
