defmodule DemoWeb.DemoLive.FormModalDemo do
  @moduledoc false
  use DemoWeb, :live_component
  import Prima.{Modal, Combobox}

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(form_modal_open?: false)
      |> assign(submitted_form_data: nil)
      |> assign(form: to_form(%{"name" => "", "category" => ""}))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.button
        id="open-form-demo-button"
        type="button"
        phx-click={
          Prima.Modal.open("form-integration-modal") |> JS.push("open-form-modal", target: @myself)
        }
      >
        Open Modal
      </.button>

      <div :if={@submitted_form_data} class="mt-4 p-4 bg-green-50 border border-green-200 rounded-md">
        <h3 class="text-sm font-medium text-green-800 mb-2">Form Submitted Successfully!</h3>
        <div class="text-sm text-green-700">
          <p><strong>Name:</strong> {@submitted_form_data.name}</p>
          <p><strong>Category:</strong> {@submitted_form_data.category}</p>
        </div>
      </div>

      <.modal
        id="form-integration-modal"
        on_close={JS.push("close-form-modal", target: @myself)}
        class="relative z-10"
      >
        <.modal_overlay
          transition_enter={{"ease-out duration-300", "opacity-0", "opacity-100"}}
          transition_leave={{"ease-in duration-200", "opacity-100", "opacity-0"}}
          class="fixed inset-0 bg-gray-500/75 transition-opacity"
        />

        <div class="fixed inset-0 w-screen overflow-y-auto">
          <div class="flex min-h-full items-end justify-center p-4 sm:items-center sm:p-0">
            <.modal_loader>
              <svg
                class="w-8 h-8 mr-2 text-white/50 animate-spin fill-white"
                viewBox="0 0 100 100"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
                  fill="currentColor"
                />
                <path
                  d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
                  fill="currentFill"
                />
              </svg>
            </.modal_loader>

            <.modal_panel
              :if={@form_modal_open?}
              id="form-integration-modal-panel"
              class="relative overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-sm sm:p-6"
              transition_enter={
                {"ease-out duration-300", "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
                 "opacity-100 translate-y-0 sm:scale-100"}
              }
              transition_leave={
                {"ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
                 "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
              }
            >
              <.form for={@form} phx-submit="save" phx-target={@myself}>
                <h2 class="text-base font-semibold leading-7 text-gray-900">New item form</h2>
                <div>
                  <label
                    for={@form[:name].name}
                    class="block text-sm font-medium leading-6 text-gray-900"
                  >
                    Name
                  </label>
                  <input
                    type="text"
                    id={@form[:name].id}
                    name={@form[:name].name}
                    value={@form[:name].value}
                    class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                  />
                </div>
                <div class="mt-4">
                  <label class="block text-sm font-medium leading-6 text-gray-900 mb-2">
                    Category
                  </label>
                  <.combobox class="w-full" id="form-modal-combobox">
                    <.combobox_input
                      name={@form[:category].name}
                      class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 cursor-default placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                      placeholder="Select a category..."
                    />

                    <.combobox_options
                      id="form-modal-combobox-options"
                      transition_leave={{"ease-in duration-100", "opacity-100", "opacity-0"}}
                      class="z-50 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-base shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm"
                    >
                      <%= for option <- ["Technology", "Design", "Marketing", "Sales", "Finance"] do %>
                        <.combobox_option
                          value={option}
                          class="group relative cursor-default select-none py-2 pl-3 pr-9 text-gray-900 data-focus:bg-indigo-600 data-focus:text-white"
                        >
                          {option}
                        </.combobox_option>
                      <% end %>
                    </.combobox_options>
                  </.combobox>
                </div>
                <div class="mt-5 sm:mt-6">
                  <.button type="submit" class="w-full">
                    <svg
                      class="w-4 h-4 mr-2 text-white/50 animate-spin fill-white hidden phx-click-loading:inline-block"
                      viewBox="0 0 100 100"
                      fill="none"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <path
                        d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
                        fill="currentColor"
                      />
                      <path
                        d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
                        fill="currentFill"
                      />
                    </svg>
                    Save
                  </.button>
                </div>
              </.form>
            </.modal_panel>
          </div>
        </div>
      </.modal>
    </div>
    """
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
  def handle_event("save", params, socket) do
    name = params["name"] || ""
    category = params["category"] || ""

    form_data = %{name: name, category: category}

    socket =
      socket
      |> assign(submitted_form_data: form_data)
      |> assign(form_modal_open?: false)

    {:noreply, socket}
  end
end
