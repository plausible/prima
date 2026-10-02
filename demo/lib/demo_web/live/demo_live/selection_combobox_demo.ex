defmodule DemoWeb.DemoLive.SelectionComboboxDemo do
  @moduledoc false
  use DemoWeb, :live_component
  import Prima.Combobox

  @countries [
    %{value: "GB", display: "United Kingdom"},
    %{value: "US", display: "United States"},
    %{value: "DE", display: "Germany"}
  ]

  @impl true
  def mount(socket) do
    {:ok, assign(socket, countries: @countries, selection: hd(@countries))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <form class="max-w-sm" phx-change="select-country" phx-target={@myself}>
      <label for="selected-country-input" class="block text-sm font-medium text-gray-700 mb-2">
        Country
      </label>
      <.combobox
        :let={input_value}
        id="selected-country"
        class="w-64"
        name="country"
        selections={@selection}
      >
        <.combobox_input
          value={input_value}
          id="selected-country-input"
          placeholder="Search countries..."
          class="block w-full rounded-md border-0 py-2 px-3 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm"
        />

        <.combobox_options
          id="selected-country-options"
          offset={4}
          class="max-h-60 w-64 overflow-auto rounded-md bg-white py-1 text-base shadow-lg ring-1 ring-gray-200 focus:outline-none sm:text-sm z-50"
        >
          <.combobox_option
            :for={country <- @countries}
            value={country.value}
            display={country.display}
            class="cursor-default select-none py-2 px-3 text-gray-900 data-focus:bg-indigo-600 data-focus:text-white data-selected:font-semibold"
          >
            {country.display}
          </.combobox_option>
        </.combobox_options>
      </.combobox>

      <button
        id="reset-country"
        type="button"
        phx-click="reset"
        phx-target={@myself}
        class="mt-3 rounded-md border border-gray-300 bg-white px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
      >
        Reset
      </button>
    </form>
    """
  end

  @impl true
  def handle_event("select-country", params, socket) do
    selection = Enum.find(@countries, &(&1.value == params["country"]))
    {:noreply, assign(socket, :selection, selection)}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, :selection, hd(@countries))}
  end
end
