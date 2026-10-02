defmodule Prima.Listbox do
  @moduledoc """
  A single-select listbox component for use as a form input.

  Unlike `Prima.Dropdown` (an action menu, `role="menu"`), `Listbox` is a value
  picker (`role="listbox"`) — selecting an option updates a hidden form field
  and the displayed value, similar to a native `<select>`.

  ## Quick Start

      <.listbox id="fruit-listbox" name="fruit" value={@selected_fruit}>
        <.listbox_trigger id="fruit-listbox-trigger">
          <.listbox_value>{@selected_fruit || "Select a fruit..."}</.listbox_value>
        </.listbox_trigger>

        <.listbox_options id="fruit-listbox-options">
          <.listbox_option id="fruit-option-apple" value="apple">Apple</.listbox_option>
          <.listbox_option id="fruit-option-banana" value="banana">Banana</.listbox_option>
        </.listbox_options>
      </.listbox>

  ## Form Integration

  `Listbox` renders a hidden `<input>` with the given `name`. Selecting an option
  updates the input's value and dispatches a bubbling `input` event, so a parent
  form's `phx-change` fires exactly like it would for a native form field:

      <form phx-change="form_changed">
        <.listbox id="fruit-listbox" name="fruit" value={@selected_fruit}>
          ...
        </.listbox>
      </form>

      def handle_event("form_changed", %{"fruit" => fruit}, socket) do
        {:noreply, assign(socket, selected_fruit: fruit)}
      end

  ## Displayed Value

  The listbox value is rendered by the caller (so the initial page load is
  always correct — no flash of placeholder text), and updated instantly on the
  client when an option is picked, ahead of any server round-trip:

      <.listbox_trigger id="fruit-listbox-trigger">
        <.listbox_value>{@selected_fruit || "Select a fruit..."}</.listbox_value>
      </.listbox_trigger>

  ## Disabling the Listbox

  Pass `disabled={true}` to `listbox` to disable the entire field. Its hidden
  input is disabled in the server-rendered HTML, excluding the value from form
  submission while preserving it for when the field is enabled again.

  On mount and LiveView updates, the JS hook applies native `disabled` to the
  trigger button, preventing interaction and removing it from the tab order.
  Disabling an open listbox closes it.

  For styling, the listbox wrapper receives `data-disabled` in the
  server-rendered HTML. Style the trigger through that ancestor, e.g. with
  Tailwind's `in-data-disabled:` variant. Avoid styling the trigger with
  `disabled:` - the native attribute is only applied once the hook mounts, so
  the disabled styling would flicker in after the initial page load.

      <.listbox id="fruit-listbox" name="fruit" value={@selected_fruit} disabled={@locked?}>
        <.listbox_trigger id="fruit-listbox-trigger" class="in-data-disabled:opacity-50">
          <.listbox_value>{@selected_fruit || "Select a fruit..."}</.listbox_value>
        </.listbox_trigger>
        <.listbox_options id="fruit-listbox-options">
          <.listbox_option id="fruit-option-apple" value="apple">Apple</.listbox_option>
        </.listbox_options>
      </.listbox>
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :value, :any, default: nil
  attr :disabled, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  def listbox(assigns) do
    ~H"""
    <div id={@id} phx-hook="Listbox" data-disabled={if @disabled, do: "true"} {@rest}>
      <input
        type="hidden"
        name={@name}
        value={@value}
        disabled={@disabled}
        data-prima-ref="value-input"
      />
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :id, :string, required: true
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  The trigger button for a listbox.

  Render a `listbox_value` within the trigger so the JS hook can update the
  displayed value without changing other content such as icons.

  ## Examples

      <.listbox_trigger id="fruit-listbox-trigger">
        <.listbox_value>{@selected_fruit || "Select a fruit..."}</.listbox_value>
        <svg class="h-5 w-5" ...>...</svg>
      </.listbox_trigger>

  ## Accessible Naming

  Labelling is up to the caller, as with a native `<select>`. The trigger's
  content is its accessible name (via `aria-labelledby`). If the trigger only
  shows the current value, put a visually hidden label next to it so that both
  the meaning and the value are announced:

      <.listbox_trigger id="role-listbox-trigger">
        <span class="sr-only">Role:</span>
        <.listbox_value>{@selected_role}</.listbox_value>
      </.listbox_trigger>

  To disable the field, pass `disabled={true}` to the parent `listbox`.
  Its JS hook synchronizes this button's native `disabled` attribute. Style the
  disabled state of this button via an `in-data-disabled:` Tailwind variant.
  """
  def listbox_trigger(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      class={@class}
      aria-haspopup="listbox"
      aria-expanded="false"
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  The displayed value within a listbox trigger.

  The JS hook updates this content when an option is selected without changing
  other trigger content.
  """
  def listbox_value(assigns) do
    ~H"""
    <span class={@class} data-prima-ref="value" {@rest}>{render_slot(@inner_block)}</span>
    """
  end

  attr :id, :string, required: true
  attr :transition_enter, :any, default: nil
  attr :transition_leave, :any, default: nil
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  # Positioning reference
  attr :reference, :string, default: nil

  # Floating UI positioning options
  attr :placement, :string,
    default: "bottom-start",
    values:
      ~w(top top-start top-end right right-start right-end bottom bottom-start bottom-end left left-start left-end)

  attr :flip, :boolean, default: true
  attr :offset, :integer, default: 4
  attr :match_trigger_width, :boolean, default: true

  # Two-div structure separates positioning from transitions, same as Dropdown's
  # menu wrapper — see lib/prima/dropdown.ex for the rationale.
  def listbox_options(assigns) do
    ~H"""
    <div
      style="display: none; position: absolute; top: 0; left: 0;"
      data-prima-ref="options-wrapper"
      data-reference={@reference}
      data-placement={@placement}
      data-flip={@flip}
      data-offset={@offset}
      data-match-trigger-width={@match_trigger_width}
    >
      <div
        id={@id}
        class={@class}
        style="display: none;"
        js-show={JS.show(transition: @transition_enter)}
        js-hide={JS.hide(transition: @transition_leave)}
        role="listbox"
        tabindex="-1"
        {@rest}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :value, :any, required: true
  attr :display, :string, default: nil
  attr :class, :string, default: ""
  attr :disabled, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  An individual selectable option within a listbox.

  ## Attributes

    * `id` (required) - Unique identifier, required for ARIA relationships
    * `value` (required) - The value submitted when this option is selected
    * `display` - The text shown in `listbox_value` when selected (defaults to `value`)
    * `disabled` - Boolean to mark the option as unselectable (default: false)
  """
  def listbox_option(assigns) do
    assigns = assign(assigns, :display_value, assigns.display || to_string(assigns.value))

    ~H"""
    <div
      id={@id}
      role="option"
      tabindex="-1"
      class={@class}
      data-value={@value}
      data-display={@display_value}
      aria-disabled={if @disabled, do: "true"}
      data-disabled={if @disabled, do: "true"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
