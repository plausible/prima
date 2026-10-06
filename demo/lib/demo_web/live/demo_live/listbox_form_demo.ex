defmodule DemoWeb.DemoLive.ListboxFormDemo do
  @moduledoc false
  use DemoWeb, :live_component
  import Prima.Listbox

  @fruits ["Cherry", "Kiwi", "Grapefruit", "Orange", "Banana"]

  @impl true
  def mount(socket) do
    {:ok, assign(socket, fruits: @fruits, selected_fruit: nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <form phx-change="favorite_fruit_changed" phx-target={@myself}>
        <.listbox id="demo-form-listbox" name="favorite_fruit" value={@selected_fruit}>
          <.listbox_trigger
            id="demo-form-listbox-trigger"
            class="w-56 inline-flex justify-between items-center rounded-lg bg-white border border-gray-300 px-3 py-2 text-sm text-gray-700 hover:bg-gray-50"
          >
            <.listbox_value>{@selected_fruit || "Select a fruit..."}</.listbox_value>
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
            id="demo-form-listbox-options"
            class="py-1 rounded-md bg-white shadow-xs ring-1 ring-gray-300 focus:outline-none"
          >
            <.listbox_option
              :for={{fruit, index} <- Enum.with_index(@fruits)}
              id={"demo-form-listbox-option-#{index}"}
              value={fruit}
              class="text-gray-700 data-focus:bg-gray-100 data-focus:text-gray-900 data-selected:font-semibold block w-full px-4 py-2 text-sm text-left"
            >
              {fruit}
            </.listbox_option>
          </.listbox_options>
        </.listbox>
      </form>

      <p class="mt-4 text-sm text-gray-600">
        Selected fruit (from server state):
        <span class="font-semibold text-gray-900">{@selected_fruit || "none"}</span>
      </p>
    </div>
    """
  end

  @impl true
  def handle_event("favorite_fruit_changed", %{"favorite_fruit" => fruit}, socket) do
    {:noreply, assign(socket, selected_fruit: fruit)}
  end
end
