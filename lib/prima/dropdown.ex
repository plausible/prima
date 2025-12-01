defmodule Prima.Dropdown do
  use Phoenix.Component
  import Prima.Component, only: [render_as: 2]
  alias Phoenix.LiveView.JS

  attr :id, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def dropdown(assigns) do
    ~H"""
    <div id={@id} phx-hook="Dropdown" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  attr :as, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  The trigger button/element for a dropdown menu.

  This component renders the clickable element that opens and closes the dropdown
  menu. By default, it renders as a `button` element, but can be customized to
  render as any component using the `as` attribute.

  ## Attributes

    * `class` - CSS classes for styling the trigger
    * `as` - Custom function component to render instead of the default button element

  ## Examples

      # Basic trigger
      <.dropdown_trigger>
        Open Menu
      </.dropdown_trigger>

      # With custom component
      <.dropdown_trigger as={&my_custom_button/1}>
        Open Menu
      </.dropdown_trigger>

  ## Custom Component Requirements

  When using the `as` attribute, the custom component receives accessibility
  attributes including `aria-haspopup="menu"` and `aria-expanded`.

  **IMPORTANT**: Custom components must accept and pass through global attributes
  using the `:global` attribute type (commonly via `@rest`). This ensures that
  Prima's accessibility attributes are properly applied to the rendered element.

  Example of a properly configured custom component:

      attr :rest, :global
      slot :inner_block, required: true

      def my_custom_button(assigns) do
        ~H\"\"\"
        <button type="button" {@rest}>
          {\render_slot(@inner_block)}
        </button>
        \"\"\"
      end

  Without `{@rest}`, accessibility attributes will not be applied and the dropdown
  will not function correctly with keyboard navigation and screen readers.
  """
  def dropdown_trigger(assigns) do
    assigns =
      assign(assigns, %{
        "aria-haspopup": "menu",
        "aria-expanded": "false"
      })

    render_as(assigns, %{tag_name: "button", type: "button"})
  end

  attr :transition_enter, :any, default: nil
  attr :transition_leave, :any, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: true

  # Positioning reference
  attr :reference, :string, default: nil

  # Floating UI positioning options
  attr :placement, :string,
    default: "bottom-end",
    values:
      ~w(top top-start top-end right right-start right-end bottom bottom-start bottom-end left left-start left-end)

  attr :flip, :boolean, default: true
  attr :offset, :integer, default: 4

  # Two-div structure separates positioning from transitions:
  # - Outer wrapper: Handles Floating UI positioning (must be display:block for measurements)
  # - Inner menu: Handles CSS transitions (starts hidden, transitions in after positioning)
  # This prevents visual "jumping" where menu briefly appears at wrong position before
  # repositioning. Floating UI cannot measure display:none elements.
  def dropdown_menu(assigns) do
    ~H"""
    <div
      style="display: none; position: absolute; top: 0; left: 0;"
      data-prima-ref="menu-wrapper"
      data-reference={@reference}
      data-placement={@placement}
      data-flip={@flip}
      data-offset={@offset}
    >
      <div
        class={@class}
        style="display: none;"
        js-show={JS.show(transition: @transition_enter)}
        js-hide={JS.hide(transition: @transition_leave)}
        role="menu"
        phx-click-away={JS.dispatch("prima:close")}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :class, :string, default: ""
  attr :disabled, :boolean, default: false
  attr :as, :any, default: nil

  # Workaround - unfortunately there seems to be no way to pass through arbitrary assigns without emitting compile warnings
  # Since dropdown items are often rendered as links, we add the <.link> attributes here as well.
  attr :rest, :global, include: ~w(navigate patch href)
  slot :inner_block, required: true

  @doc """
  A menu item component for use within a dropdown menu.

  This component represents an individual item in a dropdown menu with proper
  ARIA attributes and keyboard navigation support. By default, it renders as a
  `div` element, but can be customized to render as any component using the `as`
  attribute.

  ## Attributes

    * `class` - CSS classes for styling the menu item
    * `disabled` - Boolean to mark the item as disabled (default: false)
    * `as` - Custom function component to render instead of the default div element

  ## Examples

      # Basic menu item
      <.dropdown_item>
        Save
      </.dropdown_item>

      # Disabled menu item
      <.dropdown_item disabled={true}>
        Delete (unavailable)
      </.dropdown_item>

      # With custom component (e.g., a link)
      <.dropdown_item as={&my_link_component/1}>
        View Profile
      </.dropdown_item>

      # With Phoenix.Component.link
      <.dropdown_item as={&link/1} navigate={~p"/profile"}>
        View Profile
      </.dropdown_item>

  ## Custom Component Requirements

  When using the `as` attribute, the custom component receives all the standard
  attributes including `role="menuitem"`, `tabindex="-1"`, and accessibility
  attributes like `aria-disabled` when appropriate.

  **IMPORTANT**: Custom components must accept and pass through global attributes
  using the `:global` attribute type (commonly via `@rest`). This ensures that
  Prima's accessibility attributes are properly applied to the rendered element.

  Example of a properly configured custom component:

      attr :rest, :global
      slot :inner_block, required: true

      def my_custom_item(assigns) do
        ~H\"\"\"
        <a {@rest}>
          {\render_slot(@inner_block)}
        </a>
        \"\"\"
      end

  Without `{@rest}`, accessibility attributes will not be applied and the component
  will not function correctly with keyboard navigation and screen readers.
  """
  def dropdown_item(assigns) do
    assigns =
      assign(assigns, %{
        role: "menuitem",
        tabindex: "-1",
        "aria-disabled": if(assigns.disabled, do: "true", else: nil),
        "data-disabled": if(assigns.disabled, do: "true", else: nil)
      })

    render_as(assigns, %{tag_name: "button", type: "button"})
  end

  attr :class, :string, default: ""
  attr :rest, :global

  @doc """
  A visual separator for grouping related menu items.

  This component renders a separator line between groups of menu items to create
  visual organization within the dropdown menu. It uses the `separator` ARIA role
  for proper accessibility.

  ## Attributes

    * `class` - CSS classes for styling the separator

  ## Examples

      <.dropdown_separator class="my-1 border-t border-gray-200" />

  ## Accessibility

  The separator uses `role="separator"` which is properly announced by screen
  readers as a divider between menu sections.
  """
  def dropdown_separator(assigns) do
    ~H"""
    <div role="separator" class={@class} {@rest}></div>
    """
  end

  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  A container for grouping related menu items within a dropdown.

  This component provides semantic grouping of related menu items with proper
  ARIA structure. Use this to create logical sections within your dropdown menu.

  ## Attributes

    * `class` - CSS classes for styling the section container

  ## Examples

      # Basic section grouping
      <.dropdown_section>
        <.dropdown_item>Profile</.dropdown_item>
        <.dropdown_item>Settings</.dropdown_item>
      </.dropdown_section>

      # Section with heading
      <.dropdown_section>
        <.dropdown_heading>Account</.dropdown_heading>
        <.dropdown_item>Profile</.dropdown_item>
        <.dropdown_item>Settings</.dropdown_item>
      </.dropdown_section>

  ## Accessibility

  The section uses `role="group"` to indicate a logical grouping of menu items
  to assistive technologies. When used with a heading as the first child, the
  JavaScript hook automatically establishes the `aria-labelledby` relationship
  between the section and the heading.
  """
  def dropdown_section(assigns) do
    ~H"""
    <div role="group" class={@class} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  A heading for a group of menu items within a dropdown.

  This component provides a semantic heading for sections of menu items with
  proper ARIA labeling. When used as the first child of a `dropdown_section`,
  the JavaScript hook automatically establishes the aria-labelledby relationship.

  ## Attributes

    * `id` - Optional unique identifier for the heading. Auto-generated by the JS hook if not provided.
    * `class` - CSS classes for styling the heading

  ## Examples

      <.dropdown_section>
        <.dropdown_heading>Recent Files</.dropdown_heading>
        <.dropdown_item>Document.pdf</.dropdown_item>
        <.dropdown_item>Spreadsheet.xlsx</.dropdown_item>
      </.dropdown_section>

  ## Accessibility

  The heading uses `role="presentation"` to prevent it from being treated as
  a menu item while still providing semantic structure. When used as the first
  child of a section, the JavaScript hook automatically generates an ID for the
  heading and sets the section's `aria-labelledby` to reference it.
  """
  def dropdown_heading(assigns) do
    ~H"""
    <div id={@id} role="presentation" class={@class} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
