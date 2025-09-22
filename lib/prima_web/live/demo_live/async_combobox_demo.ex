defmodule PrimaWeb.DemoLive.AsyncComboboxDemo do
  @moduledoc false
  use PrimaWeb, :live_component
  import Prima.Combobox

  @options [
    "Cherry",
    "Kiwi",
    "Grapefruit",
    "Orange",
    "Banana"
  ]

  @impl true
  def mount(socket) do
    socket =
      socket
      |> stream_configure(:suggestions, dom_id: &"suggestions-#{&1}")
      |> stream(:suggestions, [])

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <form phx-submit="save">
      <.combobox class="relative w-64" id="demo-async-combobox">
        <div class="relative mt-2 rounded-md shadow-sm">
          <.combobox_input
            name="user[favourite_fruit]"
            class="block w-full rounded-md border-0 py-1.5 pr-10 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 cursor-default placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6 peer"
            phx-change="async_combobox_search"
            phx-target={@myself}
            placeholder="Type to search..."
          />
          <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3 invisible peer-[.phx-change-loading]:visible">
            <svg
              class="animate-spin -ml-1 h-5 w-5 text-gray-500"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
              </circle>
              <path
                class="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              >
              </path>
            </svg>
          </div>
        </div>

        <.combobox_options
          class="absolute z-10 mt-1 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-base shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm"
          phx-update="stream"
          id="demo-async-combobox-options"
        >
          <.combobox_option
            :for={{dom_id, option} <- @streams.suggestions}
            id={dom_id}
            value={option}
            class="relative cursor-default select-none py-2 pl-3 pr-9 text-gray-900 data-focus:bg-indigo-600 data-focus:text-white"
          >
            {option}
          </.combobox_option>
        </.combobox_options>
      </.combobox>
    </form>
    """
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
end
