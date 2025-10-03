defmodule Prima.Combobox do
  @moduledoc """
  A searchable dropdown component with keyboard navigation and intelligent positioning.

  The combobox combines an input field with a dropdown menu, supporting both frontend
  filtering and server-side async search. It uses Floating UI for intelligent
  positioning with automatic flipping and repositioning when scrolling or resizing.

  ## Features

  * **Keyboard Navigation** - Full arrow key navigation, Enter/Tab to select
  * **Smart Positioning** - Powered by Floating UI with automatic flipping and repositioning
  * **Dual Modes** - Frontend filtering or server-side async search
  * **Create New Items** - Optional "create new" functionality for user-generated content
  * **Multi-select** - Select more than 1 option from the options list (WIP)
  * **Accessibility** - ARIA roles, focus management, and keyboard support (WIP)
  * **Form Integration** - Can be used like any other Phoenix form field (WIP)

  ## Quick Start

  Basic combobox with predefined options and frontend filtering:

      <.combobox id="my-combobox">
        <.combobox_input name="selection" placeholder="Search options..." />

        <.combobox_options id="my-combobox-options">
          <.combobox_option value="apple">Apple</.combobox_option>
          <.combobox_option value="banana">Banana</.combobox_option>
          <.combobox_option value="orange">Orange</.combobox_option>
        </.combobox_options>
      </.combobox>

  ## Advanced Usage

  ### Server-Side Search (Async Mode)

  For large datasets or server-side filtering, add `phx-change` to the input.
  The component automatically switches to async mode when this attribute is present:

      <.combobox id="users-combobox">
        <.combobox_input
          name="user_id"
          placeholder="Search users..."
          phx-change="search-users"
        />

        <.combobox_options id="users-options" phx-update="replace">
          <%= for user <- @search_results do %>
            <.combobox_option value={user.id}><%= user.name %></.combobox_option>
          <% end %>
        </.combobox_options>
      </.combobox>

  ### Smart Positioning with Floating UI

  The options dropdown uses Floating UI for intelligent positioning:

      <.combobox_options
        id="my-options"
        placement="top-start"
        flip={true}
        offset={10}
      >
        <!-- Options content -->
      </.combobox_options>

  ### Create New Items

  Allow users to create new items that don't exist in the options list:

      <.combobox id="tags-combobox">
        <.combobox_input name="tag" placeholder="Search or create tag..." />

        <.combobox_options id="tag-options">
          <%= for tag <- @tags do %>
            <.combobox_option value={tag.name}><%= tag.name %></.combobox_option>
          <% end %>
          <.creatable_option class="italic text-gray-600" />
        </.combobox_options>
      </.combobox>

  ## Form Integration

  The combobox creates two input fields:
  * Search input: `name_search` for the user's typed query
  * Submit input: `name` for the selected value (hidden)

  This allows seamless form submission while maintaining search functionality.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  slot :inner_block, required: true
  attr :class, :string, default: ""
  attr :multiple, :boolean, default: false

  @doc """
  The main combobox container component.

  This component serves as the root container for all combobox functionality,
  managing JavaScript hook initialization and coordinating between the input
  field and options dropdown.

  ## Attributes

    * `id` (required) - Unique identifier for the combobox
    * `class` - Additional CSS classes to apply to the container
    * `inner_block` - Slot containing the input and options components

  ## Example

      <.combobox id="my-combobox" class="w-full">
        <.combobox_input name="selection" />
        <.combobox_options id="options">
          <!-- Options content -->
        </.combobox_options>
      </.combobox>

  """
  def combobox(assigns) do
    ~H"""
    <div id={@id} class={@class} phx-hook="Combobox" data-multiple={@multiple && true}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""

  slot :selection, required: true do
    attr :class, :string
  end

  @doc """
  Container for displaying selected items in multi-select mode.

  This component uses a template-based approach where JavaScript clones the selection
  slot markup to create pills for each selected value. The container uses `phx-update="ignore"`
  so LiveView doesn't interfere with client-side selection management.

  ## Attributes

    * `class` - CSS classes for the selections container
    * `selection` - Required slot that defines the markup for each selected item.
      The slot receives the selected value via `:let` and can be fully customized with CSS.

  ## Usage

      <.combobox_selections class="flex flex-wrap gap-2">
        <:selection :let={value} class="inline-flex items-center gap-1 px-2 py-1 bg-blue-100 rounded">
          <span><%= value %></span>
          <.combobox_selection_remove value={value} class="hover:bg-blue-200 rounded">
            ×
          </.combobox_selection_remove>
        </:selection>
      </.combobox_selections>

  JavaScript will clone the template and replace `__VALUE__` with actual selected values.
  """
  def combobox_selections(assigns) do
    assigns = assign(assigns, :selections_id, "selections-#{System.unique_integer([:positive])}")

    ~H"""
    <ul
      id={@selections_id}
      data-prima-ref="selections"
      phx-update="ignore"
      class={@class}
    >
      <template data-prima-ref="selection-template">
        <%= for entry <- @selection do %>
          <li data-prima-ref="selection-item" class={Map.get(entry, :class, "")}>
            {render_slot(entry, "__VALUE__")}
          </li>
        <% end %>
      </template>
    </ul>
    """
  end

  attr :class, :string, default: ""
  attr :name, :string, required: true
  attr(:rest, :global, include: ~w(placeholder phx-change phx-target))

  @doc """
  The searchable input field for the combobox.

  This component renders the main input where users type to search/filter options.
  It automatically creates both a visible search input and a hidden submit input
  for form integration. Adding `phx-change` switches the component to async mode
  for server-side filtering.

  ## Attributes

    * `name` (required) - Form field name. Creates `name_search` and `name` inputs
    * `class` - CSS classes for the visible input field
    * `placeholder` - Placeholder text for the input
    * `phx-change` - LiveView event for async search (enables async mode)
    * `phx-target` - Target for the phx-change event

  ## Examples

  ### Frontend filtering mode:

      <.combobox_input
        name="category"
        placeholder="Select category..."
        class="w-full border rounded-md px-3 py-2"
      />

  ### Async search mode:

      <.combobox_input
        name="user_id"
        placeholder="Search users..."
        phx-change="search-users"
        phx-target={@myself}
        class="w-full border rounded-md px-3 py-2"
      />

  """
  def combobox_input(assigns) do
    ~H"""
    <input
      data-prima-ref="search_input"
      type="text"
      autocomplete="off"
      class={@class}
      name={@name <> "_search"}
      tabindex="0"
      phx-debounce={200}
      {@rest}
    />
    <div phx-update="ignore" id={@name <> "_submit_container"}>
      <input data-prima-ref="submit_input" type="hidden" autocomplete="off" name={@name} />
    </div>
    """
  end

  attr :class, :string, default: ""
  slot :inner_block, required: true
  attr(:rest, :global)

  @doc """
  The field wrapper component for multi-select comboboxes.

  This component provides a stable positioning reference for the options dropdown
  in multi-select mode. When selection pills are added/removed, the input element
  shifts horizontally. By wrapping the input and selections in `combobox_field`,
  the dropdown stays anchored to this stable container instead of the moving input.

  ## Attributes

    * `class` - CSS classes for styling the field container
    * All HTML attributes are passed through (id, style, data-*, aria-*, etc.)

  ## Example

      <.combobox_field class="flex flex-wrap gap-2 border rounded-md p-2">
        <.combobox_selections>
          <!-- Selection pills -->
        </.combobox_selections>
        <.combobox_input name="tags" class="flex-1" />
      </.combobox_field>

  When `combobox_field` is not used, the dropdown positions relative to the input.
  """
  def combobox_field(assigns) do
    ~H"""
    <div data-prima-ref="field" class={@class} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :value, :string, required: true
  attr :class, :string, default: ""
  slot :inner_block, required: true
  attr(:rest, :global)

  @doc """
  Remove button for multi-select combobox selections.

  This component renders a button that removes a selected value when clicked.
  It automatically sets the required data attributes and aria-label for accessibility.

  ## Attributes

    * `value` (required) - The value to remove when clicked
    * `class` - CSS classes for styling the button
    * `inner_block` (required) - Button content (icon, text, etc.)

  ## Example

      <.combobox_selection_remove value={value} class="text-gray-500 hover:text-gray-700">
        ×
      </.combobox_selection_remove>

  """
  def combobox_selection_remove(assigns) do
    ~H"""
    <button
      type="button"
      data-prima-ref="remove-selection"
      data-value={@value}
      aria-label={"Remove #{@value}"}
      class={@class}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  slot :inner_block, required: true
  attr :class, :string, default: ""
  attr :id, :string, required: true

  # Floating UI positioning options
  attr :placement, :string,
    default: "bottom-start",
    values:
      ~w(top top-start top-end right right-start right-end bottom bottom-start bottom-end left left-start left-end)

  attr :flip, :boolean, default: true
  attr :offset, :integer, default: nil

  # LiveView transition options
  attr :transition_enter, :any, default: nil
  attr :transition_leave, :any, default: nil

  # Allow LiveView attributes like phx-update
  attr(:rest, :global, include: ~w(phx-update))

  @doc """
  The dropdown container for combobox options.

  This component renders the dropdown that contains all selectable options.
  It uses Floating UI for intelligent positioning with automatic repositioning
  when scrolling, resizing, or when the dropdown would overflow the viewport.

  ## Attributes

    * `id` (required) - Unique identifier for the options container
    * `inner_block` - Slot containing the option elements
    * `class` - CSS classes for styling the dropdown container

  ### Floating UI Positioning

    * `placement` - Dropdown position relative to input. Options: `top`, `top-start`,
      `top-end`, `right`, `right-start`, `right-end`, `bottom` (default), `bottom-start`,
      `bottom-end`, `left`, `left-start`, `left-end`
    * `flip` - Auto-flip to opposite side if no space (default: `true`)
    * `offset` - Distance in pixels from the input (default: no offset)

  By default, the dropdown positions relative to the search input. For multi-select
  comboboxes where the input shifts when pills are added/removed, use `combobox_field`
  to provide a stable positioning reference.

  ### Transitions

    * `transition_enter` - Transition for showing the dropdown
    * `transition_leave` - Transition for hiding the dropdown

  ### LiveView Integration

    * `phx-update` - LiveView update strategy for dynamic options (useful for async mode)

  ## Examples

  ### Basic options container:

      <.combobox_options id="basic-options" class="bg-white border rounded-md shadow-lg">
        <.combobox_option value="option1">Option 1</.combobox_option>
        <.combobox_option value="option2">Option 2</.combobox_option>
      </.combobox_options>

  ### With custom positioning:

      <.combobox_options
        id="positioned-options"
        placement="top-end"
        flip={false}
        offset={5}
        class="bg-white border rounded-md"
      >
        <!-- Options content -->
      </.combobox_options>

  ### For async mode with transitions:

      <.combobox_options
        id="async-options"
        phx-update="replace"
        transition_enter={{"ease-out duration-100", "opacity-0 scale-95", "opacity-100 scale-100"}}
        transition_leave={{"ease-in duration-75", "opacity-100 scale-100", "opacity-0 scale-95"}}
      >
        <%= for item <- @search_results do %>
          <.combobox_option value={item.id}><%= item.name %></.combobox_option>
        <% end %>
      </.combobox_options>

  """
  def combobox_options(assigns) do
    ~H"""
    <div
      id={@id}
      class={@class}
      style="display: none;"
      js-show={JS.show(transition: @transition_enter)}
      js-hide={JS.hide(transition: @transition_leave)}
      phx-click-away={JS.dispatch("prima:combobox:reset")}
      data-prima-ref="options"
      data-placement={@placement}
      data-flip={@flip}
      data-offset={@offset}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  attr :value, :any, required: true
  slot :inner_block, required: true
  attr(:rest, :global)

  @doc """
  An individual selectable option within the combobox dropdown.

  Each option represents a selectable item in the dropdown. Options support
  keyboard navigation, mouse hover, and click selection. In frontend mode,
  options are automatically filtered based on the search input.

  ## Attributes

    * `value` (required) - The value submitted when this option is selected
    * `inner_block` - The display content for the option
    * `class` - CSS classes for styling the option

  ## State Attributes

  The component automatically adds HTML data attributes for styling:

    * `data-focus` - Set to `"true"` when the option is focused (keyboard/hover)
    * `data-selected` - Set to `"true"` when the option is currently selected

  Use these attributes to style options based on their state:

      /* Style focused option */
      .option[data-focus="true"] { background-color: #f3f4f6; }

      /* Style selected option */
      .option[data-selected="true"] { font-weight: 600; }

  ## Examples

  ### Basic option:

      <.combobox_option value="apple" class="px-3 py-2 hover:bg-gray-100">
        🍎 Apple
      </.combobox_option>

  ### With complex content and state styling:

      <.combobox_option
        value={user.id}
        class="px-3 py-2 flex items-center data-focus:bg-indigo-600 data-selected:font-semibold"
      >
        <img src={user.avatar} class="w-6 h-6 rounded-full mr-2" />
        <div>
          <div class="font-medium"><%= user.name %></div>
          <div class="text-sm text-gray-500"><%= user.email %></div>
        </div>
      </.combobox_option>

  """
  def combobox_option(assigns) do
    ~H"""
    <div role="option" class={@class} data-value={@value} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""

  @doc """
  A special option that allows users to create new items.

  This component enables users to select values that don't exist in the predefined
  options list. It automatically shows/hides based on the search input and whether
  an exact match exists in the current options.

  ## Behavior

  * **Auto-generated content**: Displays "Create \\"[search_term]\\"" based on current input
  * **Smart visibility**: Only shows when search input has content and no exact match exists

  ## Attributes

    * `class` - CSS classes for styling the create option

  ## Example

      <.combobox id="tags-input">
        <.combobox_input name="new_tag" placeholder="Search or create tag..." />

        <.combobox_options id="tag-options">
          <%= for tag <- @existing_tags do %>
            <.combobox_option value={tag}><%= tag %></.combobox_option>
          <% end %>

          <.creatable_option class="px-3 py-2 italic text-blue-600 border-t" />
        </.combobox_options>
      </.combobox>

  When user types "new-tag" and it doesn't exist in options, this will show:
  "Create 'new-tag'" and submit "new-tag" as the value when selected.

  """
  def creatable_option(assigns) do
    ~H"""
    <div
      role="option"
      data-prima-ref="create-option"
      data-value="__CREATE__"
      class={@class}
    >
    </div>
    """
  end
end
