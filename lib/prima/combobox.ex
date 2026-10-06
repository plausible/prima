defmodule Prima.Combobox do
  @moduledoc """
  A searchable dropdown component with keyboard navigation and intelligent positioning.

  The combobox combines an input field with a dropdown menu, supporting both frontend
  filtering and server-side async search. It uses Floating UI for intelligent
  positioning with automatic flipping and repositioning when scrolling or resizing.

  ## Features

  * **Keyboard Navigation** - Arrow key navigation and Enter to select; Tab moves focus onward and discards unfinished search
  * **Smart Positioning** - Powered by Floating UI with automatic flipping and repositioning
  * **Dual Modes** - Frontend filtering or server-side async search
  * **Create New Items** - Optional "create new" functionality for user-generated content
  * **Multi-select** - Select more than 1 option from the options list (WIP)
  * **Accessibility** - ARIA roles, focus management, and keyboard support (WIP)
  * **Form Integration** - Can be used like any other Phoenix form field (WIP)

  ## Quick Start

  Basic combobox with predefined options and frontend filtering:

      <.combobox id="my-combobox" name="selection">
        <.combobox_input placeholder="Search options..." />

        <.combobox_options id="my-combobox-options">
          <.combobox_option value="apple">Apple</.combobox_option>
          <.combobox_option value="banana">Banana</.combobox_option>
          <.combobox_option value="orange">Orange</.combobox_option>
        </.combobox_options>
      </.combobox>

  ## Advanced Usage

  ### Server-Side Search (Async Mode)

  For large datasets or server-side filtering, add `on_search` to the search input.
  The component automatically switches to async mode when this attribute is present:

      <.combobox id="users-combobox" name="user_id">
        <.combobox_input
          placeholder="Search users..."
          on_search="search-users"
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

      <.combobox id="tags-combobox" name="tag">
        <.combobox_input placeholder="Search or create tag..." />

        <.combobox_options id="tag-options">
          <%= for tag <- @tags do %>
            <.combobox_option value={tag.name}><%= tag.name %></.combobox_option>
          <% end %>
          <.creatable_option class="italic text-gray-600" />
        </.combobox_options>
      </.combobox>

  ## Form Integration

  Comboboxes are backed by a native `<select>` and follow its form-submission behavior.
  Only selected option values are submitted, never the search text.

  The `name` is used exactly as supplied. For Phoenix forms, use `name="fruit"` for a
  single value and `name="fruits[]"` for a list of values in multiple mode.

  When nothing is selected, the field is omitted from form data. Selecting an option
  with `value=""` submits an empty string. Multiple mode does not submit an empty list
  automatically.

  A parent form's `phx-change` fires when selections are added or removed. Typing only
  filters options or sends an `on_search` event with `%{"query" => query}`.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :selections, :any
  slot :inner_block, required: true
  attr :class, :string, default: ""
  attr :multiple, :boolean, default: false
  attr(:rest, :global)

  @doc """
  The main combobox container component.

  Wrap the input, options, and optional selections in this component.

  ## Attributes

    * `id` (required) - Unique identifier for the combobox
    * `name` (required) - Submitted field name, used verbatim. Include `[]` for
      Phoenix list parameters in multiple mode (for example, `name="roles[]"`).
    * `selections` - A map with a required `:value` and optional `:display`, or a list
      of these maps in multiple mode.
    * `class` - Additional CSS classes to apply to the container
    * `multiple` - Enable multi-select mode (default: `false`)
    * `inner_block` - Slot containing the input and options components. Use `:let`
      to receive the initial input text for server rendering.

  ## Example

      <.combobox id="my-combobox" class="w-full" phx-change="selection_changed" name="selection">
        <.combobox_input />
        <.combobox_options id="options">
          <!-- Options content -->
        </.combobox_options>
      </.combobox>

  """
  def combobox(assigns) do
    assigns = assign(assigns, :has_selections, Map.has_key?(assigns, :selections))

    selections =
      for item <- List.wrap(assigns[:selections]) do
        [to_string(item.value), item[:display]]
      end

    input_value =
      case {assigns.multiple, selections} do
        {false, [[value, display] | _]} -> display || value
        _ -> ""
      end

    assigns = assign(assigns, selections: selections, input_value: input_value)

    ~H"""
    <div id={@id} class={@class} phx-hook="Combobox" data-multiple={@multiple && true} {@rest}>
      <select
        id={@id <> "_submit"}
        name={@name}
        multiple={@multiple}
        phx-update="ignore"
        data-selection={@has_selections && Phoenix.json_library().encode!(@selections)}
        data-prima-ref="submit_input"
        hidden
      >
        <option :for={[value, label] <- @selections} value={value} selected>
          {label || value}
        </option>
      </select>
      {render_slot(@inner_block, @input_value)}
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
      Use `combobox_selection_label` for the display label and `combobox_selection_remove`
      for a remove button. The surrounding markup can be fully customized.

  ## Usage

      <.combobox_selections class="flex flex-wrap gap-2">
        <:selection class="inline-flex items-center gap-1 px-2 py-1 bg-blue-100 rounded">
          <.combobox_selection_label />
          <.combobox_selection_remove class="hover:bg-blue-200 rounded">
            ×
          </.combobox_selection_remove>
        </:selection>
      </.combobox_selections>
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
            {render_slot(entry)}
          </li>
        <% end %>
      </template>
    </ul>
    """
  end

  attr :class, :string, default: ""
  attr :value, :string, default: ""
  attr :on_search, :string, default: nil
  attr :search_debounce, :integer, default: 200
  attr(:rest, :global, include: ~w(placeholder phx-target))

  @doc """
  The searchable input field for the combobox.

  Filters options locally by default. Set `on_search` to an event name to search
  on the server instead; no enclosing form is required. The handler receives
  `%{"query" => query}` and should return default options when the query is empty.

  ## Attributes

    * `value` - Initial input text, supplied by the root's `:let` when using `selections`.
    * `class` - CSS classes for the visible input field
    * `placeholder` - Placeholder text for the input
    * `on_search` - Event name for async search (enables async mode)
    * `phx-target` - Optional LiveComponent target for the search event
    * `search_debounce` - Typing delay in milliseconds (default: 200; use 0 for no delay)

  ## Examples

  ### Initial selection:

      <.combobox
        id="user-combobox"
        name="user_id"
        selections={%{value: @user.id, display: @user.name}}
        :let={input_value}
      >
        <.combobox_input value={input_value} />
        <.combobox_options id="user-options">
          <!-- Options content -->
        </.combobox_options>
      </.combobox>

  Without initial selections, omit both `:let` and the input's `value`.
  Omitting `selections` preserves the current selection across server patches.

  Use the list form inside a combobox with `multiple={true}`. Server patches apply
  `selections` while the search input is unfocused. While it is focused,
  the current selection and search text are preserved, like a native text input.
  Blurring does not apply a skipped update; a subsequent patch can apply it.

  Build `selections` from your form state and update it in your `phx-change` handler so
  later patches retain the user's selection. Applying server values does not
  fire a form change event.

  ### Frontend filtering mode:

      <.combobox_input
        placeholder="Select category..."
        class="w-full border rounded-md px-3 py-2"
      />

  ### Async search mode:

      <.combobox_input
        placeholder="Search users..."
        on_search="search-users"
        phx-target={@myself}
        class="w-full border rounded-md px-3 py-2"
      />

  """
  def combobox_input(assigns) do
    ~H"""
    <input
      data-prima-ref="search_input"
      data-on-search={@on_search}
      data-search-debounce={@search_debounce}
      type="text"
      value={@value}
      role="combobox"
      aria-expanded="false"
      aria-autocomplete="list"
      aria-haspopup="listbox"
      autocomplete="off"
      class={@class}
      tabindex="0"
      phx-update="ignore"
      {@rest}
    />
    """
  end

  attr :class, :string, default: ""
  attr(:rest, :global)

  @doc """
  Display label for a selected item within a `combobox_selections` template.

  JavaScript fills this span with the option's `display` text, falling back to its
  value. Use surrounding markup for icons or other content that should be preserved.
  """
  def combobox_selection_label(assigns) do
    ~H"""
    <span data-prima-ref="selection-label" class={@class} {@rest}></span>
    """
  end

  attr :class, :string, default: ""
  slot :inner_block, required: true
  attr(:rest, :global)

  @doc """
  Remove button for multi-select combobox selections.

  Use this button inside a `combobox_selections` template. JavaScript binds it to
  the selected item's submitted value and sets an aria-label using its display label.
  A caller-provided `aria-label` is preserved.

  ## Attributes

    * `class` - CSS classes for styling the button
    * `inner_block` (required) - Button content (icon, text, etc.)

  ## Example

      <.combobox_selection_remove class="text-gray-500 hover:text-gray-700">
        ×
      </.combobox_selection_remove>

  """
  def combobox_selection_remove(assigns) do
    ~H"""
    <button
      type="button"
      data-prima-ref="remove-selection"
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

  # Positioning reference
  attr :reference, :string, default: nil

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

  ### Positioning Reference

    * `reference` - CSS selector for the element to position relative to (default: positions relative to the search input)

  For multi-select comboboxes where the input shifts when selection pills are added/removed,
  you can specify a stable container element as the positioning reference using any valid CSS selector
  (e.g., "#my-field", ".field-wrapper", "[data-ref='field']").

  ### Floating UI Positioning

    * `placement` - Dropdown position relative to reference. Options: `top`, `top-start`,
      `top-end`, `right`, `right-start`, `right-end`, `bottom` (default), `bottom-start`,
      `bottom-end`, `left`, `left-start`, `left-end`
    * `flip` - Auto-flip to opposite side if no space (default: `true`)
    * `offset` - Distance in pixels from the reference element (default: no offset)

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

  # Two-div structure separates positioning from transitions:
  # - Outer wrapper: Handles Floating UI positioning (must be display:block for measurements)
  # - Inner options: Handles CSS transitions (starts hidden, transitions in after positioning)
  # This prevents visual "jumping" where options briefly appear at wrong position before
  # repositioning. Floating UI cannot measure display:none elements.
  def combobox_options(assigns) do
    ~H"""
    <div
      style="position: absolute; top: 0; left: 0;"
      phx-mounted={JS.ignore_attributes("style")}
      data-prima-ref="options-wrapper"
      data-reference={@reference}
      data-placement={@placement}
      data-flip={@flip}
      data-offset={@offset}
    >
      <div
        id={@id}
        role="listbox"
        class={@class}
        style="display: none;"
        js-show={JS.show(transition: @transition_enter)}
        js-hide={JS.hide(transition: @transition_leave)}
        data-prima-ref="options"
        {@rest}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :class, :string, default: ""
  attr :value, :any, required: true
  attr :display, :string, default: nil
  slot :inner_block, required: true
  attr(:rest, :global)

  @doc """
  An individual selectable option within the combobox dropdown.

  Each option represents a selectable item in the dropdown. Options support
  keyboard navigation, mouse hover, and click selection. In frontend mode,
  options are automatically filtered based on the search input.

  ## Attributes

    * `value` (required) - The value submitted when this option is selected
    * `display` - The display value shown in the search input (defaults to `value` if not provided)
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
    assigns = assign(assigns, :display_value, assigns.display || to_string(assigns.value))

    ~H"""
    <div role="option" class={@class} data-value={@value} data-display={@display_value} {@rest}>
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

      <.combobox id="tags-input" name="new_tag">
        <.combobox_input placeholder="Search or create tag..." />

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
