defmodule Prima.Modal do
  @moduledoc """
  A fully-managed dialog component with accessibility features and smooth transitions.

  Modals can be loaded asynchronously from the server, integrated with forms, and
  paired with live navigation for deep linking capabilities.

  ## Quick Start

  The most basic modal requires just a trigger button and three components:
  `.modal`, `.modal_overlay`, and `.modal_panel`.

      <.button phx-click={Prima.Modal.JS.open("my-modal")}>
        Open Modal
      </.button>

      <.modal id="my-modal">
        <.modal_overlay class="fixed inset-0 bg-gray-500/75" />
        <div class="fixed inset-0 z-10 w-screen overflow-y-auto">
          <div class="flex min-h-full items-end justify-center p-4">
            <.modal_panel id="my-modal-panel" class="relative overflow-hidden rounded-lg bg-white">
              <p>Modal content</p>
            </.modal_panel>
          </div>
        </div>
      </.modal>

  ## Focus Management

  By default, the modal panel itself receives focus when opened. To focus a specific
  element instead, add the `data-autofocus` attribute:

      <.modal_panel id="form-panel">
        <input type="text" data-autofocus placeholder="Name" />
      </.modal_panel>

  Focus is automatically restored to the triggering element when the modal closes.


  ## Modal Control Patterns

  There are two main patterns for controlling modal visibility, each suited to different use cases.

  ### Frontend Modals (Client-Side Control)

  Frontend modals are always rendered in the DOM and controlled via JavaScript commands.
  They're ideal for simple interactions that don't require server-side state.

  **Opening/Closing from the Client:**

      <.button phx-click={Prima.Modal.JS.open("my-modal")}>Open</.button>
      <.button phx-click={Prima.Modal.JS.close()}>Close</.button>

  **Opening/Closing from the Backend:**

  Use `Prima.Modal.push_open/2` and `Prima.Modal.push_close/2`:

      def handle_event("close_modal", _params, socket) do
        {:noreply, Prima.Modal.push_close(socket)}
      end

  To target a specific modal when multiple are present, pass the modal's `id`:

      {:noreply, Prima.Modal.push_open(socket, "settings-modal")}

  ### Async Modals (Server-Side Control)

  Async modals are controlled by conditionally rendering the modal panel based on
  a LiveView assign. They're ideal when you need to load data before showing the modal.

  **Opening from the Client:**

      <.button phx-click={Prima.Modal.JS.open("async-modal") |> JS.push("load_data")}>
        Open
      </.button>

      def handle_event("load_data", _params, socket) do
        {:noreply, assign(socket, show_modal: true)}
      end

      <.modal_panel :if={@show_modal} id="async-modal-panel">
        <!-- Content -->
      </.modal_panel>

  **Closing from the Client:**

  User clicks close button, which triggers backend update via `on_close`:

      <.modal on_close={JS.push("close_modal")}>
        <!-- ... -->
      </.modal>

      def handle_event("close_modal", _params, socket) do
        {:noreply, assign(socket, show_modal: false)}
      end

  **Closing from the Backend:**

  Simply update the assign to remove the panel:

      def handle_event("submit_form", params, socket) do
        # Process form...
        {:noreply, assign(socket, show_modal: false)}
      end
  """
  use Phoenix.Component
  import Prima.Component, only: [render_as: 2]
  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :class, :string, default: ""
  attr :on_close, JS, default: %JS{}
  attr :show, :boolean, default: false

  slot :inner_block

  @doc """
  The main modal container component.

  This component manages the modal's visibility state and provides the foundation
  for other modal components. It automatically handles focus management, escape key
  handling, and accessibility attributes.

  ## Attributes

    * `id` (required) - Unique identifier for the modal
    * `class` - Additional CSS classes to apply
    * `on_close` - JavaScript commands to execute when modal closes
    * `show` - Boolean indicating initial visibility state

  ## Example

      <.modal id="my-modal">
        <.modal_overlay />
        <.modal_panel id="my-panel">
          Modal content
        </.modal_panel>
      </.modal>

  """
  def modal(assigns) do
    ~H"""
    <.portal id={"#{@id}-portal"} target="body">
      <div
        id={@id}
        js-show={JS.show()}
        js-hide={@on_close |> JS.hide()}
        data-prima-show={@show}
        style="display: none;"
        phx-hook="Modal"
        class={@class}
        role="dialog"
        aria-modal="true"
        aria-hidden="true"
      >
        {render_slot(@inner_block)}
      </div>
    </.portal>
    """
  end

  attr :class, :string, default: ""
  attr :transition_enter, :any, default: nil
  attr :transition_leave, :any, default: nil

  @doc """
  A backdrop overlay for the modal.

  This component provides the semi-transparent overlay that appears behind
  the modal content. It supports customizable enter/leave transitions.

  ## Attributes

    * `class` - CSS classes for styling the overlay
    * `transition_enter` - Transition configuration for showing the overlay
    * `transition_leave` - Transition configuration for hiding the overlay

  ## Example

      <.modal_overlay
        class="fixed inset-0 bg-gray-500/75"
        transition_enter={{"ease-out duration-300", "opacity-0", "opacity-100"}}
        transition_leave={{"ease-in duration-200", "opacity-100", "opacity-0"}}
      />

  """
  def modal_overlay(assigns) do
    ~H"""
    <div
      style="display: none;"
      js-show={JS.show(transition: @transition_enter)}
      js-hide={JS.hide(transition: @transition_leave)}
      data-prima-ref="modal-overlay"
      class={@class}
    >
    </div>
    """
  end

  slot :inner_block

  @doc """
  A loading indicator component for async modals.

  This component displays while the modal is in a loading state, typically
  used for async modals where content is fetched from the server before
  displaying the main modal panel.

  ## Example

      <.modal_loader>
        <div class="spinner">Loading...</div>
      </.modal_loader>

  """
  def modal_loader(assigns) do
    ~H"""
    <div data-prima-ref="modal-loader" js-show={JS.show()} js-hide={JS.hide()}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :id, :string, required: true
  attr :class, :string, default: ""
  attr :transition_enter, :any, default: nil
  attr :transition_leave, :any, default: nil
  slot :inner_block

  @doc """
  The main content panel of the modal.

  This component contains the actual modal content and handles focus management,
  keyboard navigation (escape key), and click-away behavior. It automatically
  wraps content in a focus trap for accessibility.

  ## Focus Management

  When a modal opens, focus is managed as follows:

    * If an element with `data-autofocus` attribute exists within the modal,
      that element will receive focus
    * Otherwise, the first focusable element within the modal panel will
      receive focus automatically

  When the modal closes, focus is automatically restored to the element that
  triggered the modal.

  ## Attributes

    * `id` (required) - Unique identifier for the panel
    * `class` - CSS classes for styling the panel
    * `transition_enter` - Transition configuration for showing the panel
    * `transition_leave` - Transition configuration for hiding the panel

  ## Examples

      # Basic modal - first focusable element receives focus by default
      <.modal_panel
        id="my-panel"
        class="relative overflow-hidden rounded-lg bg-white"
        transition_enter={{"ease-out duration-300", "opacity-0 scale-95", "opacity-100 scale-100"}}
      >
        <h2>Modal Title</h2>
        <p>Modal content goes here</p>
        <button phx-click={Modal.close()}>Close</button>
      </.modal_panel>

      # Modal with autofocus on a specific element
      <.modal_panel id="form-panel" class="...">
        <h2>Edit Profile</h2>
        <input type="text" name="name" data-autofocus placeholder="Enter name" />
        <button type="submit">Save</button>
      </.modal_panel>

  """
  def modal_panel(assigns) do
    ~H"""
    <div
      style="display: none;"
      js-show={JS.show(transition: @transition_enter)}
      js-hide={JS.hide(transition: @transition_leave)}
      js-focus-first={JS.focus_first()}
      phx-mounted={panel_mounted()}
      phx-remove={panel_removed()}
      data-prima-ref="modal-panel"
      phx-window-keydown={Prima.Modal.JS.close()}
      phx-key="escape"
      phx-click-away={Prima.Modal.JS.close()}
    >
      <.focus_wrap id={@id} class={@class}>
        {render_slot(@inner_block)}
      </.focus_wrap>
    </div>
    """
  end

  @doc false
  def panel_removed() do
    JS.dispatch("prima:modal:panel-removed")
  end

  @doc false
  def panel_mounted() do
    JS.dispatch("prima:modal:panel-mounted")
  end

  defmodule JS do
    @moduledoc """
    JavaScript commands for client-side modal control.
    """
    alias Phoenix.LiveView.JS

    @doc """
    Opens a modal with the given ID.

    This function dispatches a JavaScript event to show the modal. The modal
    must already be rendered in the DOM with the corresponding ID.

    ## Parameters

      * `id` - The ID of the modal to open (string)

    ## Example

        <.button phx-click={Prima.Modal.JS.open("my-modal")}>
          Open Modal
        </.button>

    """
    def open(id) do
      JS.dispatch("prima:modal:open", to: "##{id}")
    end

    @doc """
    Opens a modal with the given ID, chaining with existing JS commands.

    This function allows you to chain modal opening with other JavaScript
    commands, enabling complex interactions like navigation combined with
    modal display.

    ## Parameters

      * `js` - A `Phoenix.LiveView.JS` struct containing previous commands
      * `id` - The ID of the modal to open (string)

    ## Example

        # Chain with navigation
        <.button phx-click={JS.patch("/modal/history") |> Prima.Modal.JS.open("my-modal")}>
          Navigate and Open Modal
        </.button>

        # Chain with custom events
        <.button phx-click={JS.push("track") |> Prima.Modal.JS.open("my-modal")}>
          Track and Open
        </.button>

    """
    def open(%JS{} = js, id) do
      JS.dispatch(js, "prima:modal:open", to: "##{id}")
    end

    @doc """
    Closes the currently open modal.

    This function dispatches a JavaScript event to close any open modal.
    It can be used from buttons, form submissions, or other user interactions.

    ## Example

        <.button phx-click={Prima.Modal.JS.close()}>
          Close
        </.button>

        # Chain with other JS commands
        <.button phx-click={Prima.Modal.JS.close() |> JS.push("modal-closed")}>
          Close and Notify
        </.button>

    """
    def close() do
      JS.dispatch("prima:modal:close")
    end
  end

  @doc """
  Pushes an event to open a modal from the backend.

  Use this in LiveView event handlers to open a modal via `push_event/3`.

  ## Parameters

    * `socket` - The LiveView socket
    * `id` - Optional modal ID to target a specific modal

  ## Examples

      # Open a specific modal
      def handle_event("show_settings", _params, socket) do
        {:noreply, Prima.Modal.push_open(socket, "settings-modal")}
      end

      # Open all modals (when id is nil)
      def handle_event("show_modal", _params, socket) do
        {:noreply, Prima.Modal.push_open(socket)}
      end

  """
  def push_open(socket, id \\ nil) do
    payload = if id, do: %{id: id}, else: %{}
    Phoenix.LiveView.push_event(socket, "prima:modal:open", payload)
  end

  @doc """
  Pushes an event to close a modal from the backend.

  Use this in LiveView event handlers to close a modal via `push_event/3`.

  ## Parameters

    * `socket` - The LiveView socket
    * `id` - Optional modal ID to target a specific modal

  ## Examples

      # Close a specific modal
      def handle_event("dismiss_notification", _params, socket) do
        {:noreply, Prima.Modal.push_close(socket, "notification-modal")}
      end

      # Close all modals (when id is nil)
      def handle_event("close_modals", _params, socket) do
        {:noreply, Prima.Modal.push_close(socket)}
      end

  """
  def push_close(socket, id \\ nil) do
    payload = if id, do: %{id: id}, else: %{}
    Phoenix.LiveView.push_event(socket, "prima:modal:close", payload)
  end

  attr :class, :string, default: nil
  attr :as, :any, default: "h3"
  slot :inner_block, required: true

  @doc """
  A title component for the modal.

  This component provides the accessible title for the modal dialog.
  It automatically generates an ID that will be referenced by the modal
  container's aria-labelledby attribute.

  ## Attributes

    * `class` - CSS classes for styling the title
    * `as` - Custom function component to render instead of default h3 tag

  ## Example

      <.modal_title class="text-lg font-semibold">
        Confirm Action
      </.modal_title>

      # With custom component
      <.modal_title as={&my_custom_heading/1}>
        Custom Title
      </.modal_title>

  """
  def modal_title(assigns) do
    assigns =
      assign(assigns, %{
        "data-prima-ref": "modal-title"
      })

    render_as(assigns, %{tag_name: "h3"})
  end
end
