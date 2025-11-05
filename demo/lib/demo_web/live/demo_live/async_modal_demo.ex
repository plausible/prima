defmodule DemoWeb.DemoLive.AsyncModalDemo do
  @moduledoc false
  use DemoWeb, :live_component
  import Prima.Modal

  @impl true
  def mount(socket) do
    socket = assign(socket, async_modal_open?: false)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.button
        id="open-form-modal-button"
        type="button"
        phx-click={
          Prima.Modal.JS.open("demo-form-modal") |> JS.push("open-async-modal", target: @myself)
        }
        class="inline-flex justify-center rounded-md bg-indigo-600 disabled:bg-gray-400 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
      >
        Open Async Modal
      </.button>

      <.modal
        id="demo-form-modal"
        on_close={JS.push("close-async-modal", target: @myself)}
        class="relative z-10"
      >
        <.modal_overlay
          transition_enter={{"ease-out duration-300", "opacity-0", "opacity-100"}}
          transition_leave={{"ease-in duration-200", "opacity-100", "opacity-0"}}
          class="fixed inset-0 bg-gray-500/75 transition-opacity"
        />

        <div class="fixed inset-0 z-10 w-screen overflow-y-auto">
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
              :if={@async_modal_open?}
              id="demo-form-modal-panel"
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
              <div class="relative">
                <button
                  class="absolute top-0 right-0"
                  phx-click={Prima.Modal.JS.close()}
                  testing-ref="close-button"
                >
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke-width="1.5"
                    stroke="currentColor"
                    class="text-gray-600 h-6 w-6"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                  </svg>
                </button>
                <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-blue-100">
                  <svg
                    class="h-6 w-6 text-blue-600"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke-width="1.5"
                    stroke="currentColor"
                    aria-hidden="true"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      d="M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l3.5-1.75a.75.75 0 000-1.342l-3.5-1.75a.75.75 0 00-1.063.853l.708 2.836z"
                    />
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                </div>
                <div class="mt-3 text-center sm:mt-5">
                  <h2
                    class="text-base font-semibold leading-6 text-gray-900"
                    id="demo-form-modal-title"
                  >
                    Data loaded successfully
                  </h2>
                  <div class="mt-2">
                    <p class="text-sm text-gray-500">
                      This modal demonstrates loading states and backend synchronization.
                    </p>
                  </div>
                </div>
              </div>
              <form class="mt-5 sm:mt-6">
                <button
                  phx-click={JS.push("close-async-modal", target: @myself)}
                  type="button"
                  class="inline-flex w-full justify-center rounded-md bg-blue-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
                >
                  Save
                </button>
              </form>
            </.modal_panel>
          </div>
        </div>
      </.modal>
    </div>
    """
  end

  @impl true
  def handle_event("open-async-modal", _params, socket) do
    {:noreply, assign(socket, async_modal_open?: true)}
  end

  @impl true
  def handle_event("close-async-modal", _params, socket) do
    {:noreply, assign(socket, async_modal_open?: false)}
  end
end
