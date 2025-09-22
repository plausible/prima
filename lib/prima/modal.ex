defmodule Prima.Modal do
  @moduledoc """
  A fully-managed dialog component with accessibility features and smooth transitions.

  Modals can be loaded asynchronously from the server, integrated with forms, and
  paired with live navigation for deep linking capabilities.

  ## Quick Start

  The most basic modal requires just a trigger button and three components:
  `.modal`, `.modal_overlay`, and `.modal_panel`.

      <.button phx-click={Prima.Modal.open("my-modal")}>
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

  ## Advanced Usage

  ### Async Loading

  Asynchronous modals enable server-side data fetching before displaying content.
  This pattern is ideal when you need to load user-specific data or perform
  database queries before showing modal content.

      <.button phx-click={Prima.Modal.open("async-modal") |> JS.push("load-data")}>
        Open Async Modal
      </.button>

      <.modal id="async-modal" on_close={JS.push("close-modal")}>
        <.modal_loader>
          <div class="spinner">Loading...</div>
        </.modal_loader>

        <.modal_panel :if={@data_loaded?} id="async-modal-panel">
          <!-- Content rendered after async operation -->
        </.modal_panel>
      </.modal>

  ### Form Integration

  Modals work seamlessly with Phoenix forms, validation, and submission handling.
  Use the `on_close` attribute to chain JavaScript commands with LiveView events
  for backend state synchronization.

  ### Browser History

  Integrate modals with browser navigation for bookmarkable and shareable modal states
  by using Phoenix LiveView routing.
  """
  use Phoenix.Component
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
      prima-ref="modal-overlay"
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
    <div prima-ref="modal-loader" js-show={JS.show()} js-hide={JS.hide()}>
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

  ## Attributes

    * `id` (required) - Unique identifier for the panel
    * `class` - CSS classes for styling the panel
    * `transition_enter` - Transition configuration for showing the panel
    * `transition_leave` - Transition configuration for hiding the panel

  ## Example

      <.modal_panel
        id="my-panel"
        class="relative overflow-hidden rounded-lg bg-white"
        transition_enter={{"ease-out duration-300", "opacity-0 scale-95", "opacity-100 scale-100"}}
      >
        <h2>Modal Title</h2>
        <p>Modal content goes here</p>
      </.modal_panel>

  """
  def modal_panel(assigns) do
    ~H"""
    <div
      style="display: none;"
      js-show={JS.show(transition: @transition_enter)}
      js-hide={JS.hide(transition: @transition_leave)}
      phx-mounted={panel_mounted()}
      phx-remove={panel_removed()}
      prima-ref="modal-panel"
      phx-window-keydown={close()}
      phx-key="escape"
      phx-click-away={close()}
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

  @doc """
  Opens a modal with the given ID.

  This function dispatches a JavaScript event to show the modal. The modal
  must already be rendered in the DOM with the corresponding ID.

  ## Parameters

    * `id` - The ID of the modal to open (string)

  ## Example

      <.button phx-click={Prima.Modal.open("my-modal")}>
        Open Modal
      </.button>

  """
  def open(id) do
    JS.dispatch("prima:modal:open", to: "##{id}")
  end

  @doc """
  Closes the currently open modal.

  This function dispatches a JavaScript event to close any open modal.
  It can be used from buttons, form submissions, or other user interactions.

  ## Example

      <.button phx-click={Prima.Modal.close()}>
        Close
      </.button>

      # Chain with other JS commands
      <.button phx-click={Prima.Modal.close() |> JS.push("modal-closed")}>
        Close and Notify
      </.button>

  """
  def close() do
    JS.dispatch("prima:modal:close")
  end

  attr :class, :string, default: ""
  attr :as, :any, default: nil
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
        "prima-ref": "modal-title"
      })

    if assigns[:as] do
      {as, assigns} = Map.pop(assigns, :as)
      as.(assigns)
    else
      dynamic_tag(
        Map.merge(assigns, %{
          tag_name: "h3"
        })
      )
    end
  end
end
