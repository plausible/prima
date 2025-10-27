# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Prima is a Phoenix LiveView component library providing unstyled, accessible UI components. It's designed as a reusable library that developers can integrate into Phoenix applications and style according to their needs.

## Essential Commands

### Setup & Dependencies
```bash
mix setup                # Full setup (deps, assets setup, assets build)
mix deps.get            # Get Elixir dependencies
mix assets.setup        # Install Tailwind and esbuild
```

### Development
```bash
# Check if server is already running at localhost:4000 before starting
mix phx.server          # Start development server (demo app at localhost:4000)
mix assets.build        # Build assets for development
```

### Testing
```bash
mix test                    # Run ExUnit tests (includes esbuild default build)
mix test path/to/file       # Run ExUnit tests for a single file
mix test path/to/file:123   # Run a single ExUnit test starting on the given line number
```

For Wallaby browser tests specifically:
- Tests are in `test/wallaby/prima_web/`
- ChromeDriver-based integration tests for UI interactions
- Run with standard `mix test` command

## Architecture & Component Patterns

### Core Architecture
The library follows a three-layer pattern for each component:
1. **Phoenix Component** (`lib/prima/*.ex`) - Server-side rendering and LiveView integration
2. **JavaScript Hook** (`assets/js/hooks/*.js`) - Client-side behavior and DOM manipulation
3. **CSS Integration** - Tailwind-based styling with standard data attribute selectors

### Component Structure
```elixir
# Standard component pattern
defmodule Prima.ComponentName do
  use Phoenix.Component

  # Main component function with slots and attributes
  attr :id, :string, required: true
  slot :inner_block, required: true
  def component_name(assigns) do
    ~H"""
    <div phx-hook="ComponentName" prima-ref={@id}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
```

### Custom Data Attributes
- `data-prima-ref` - Component instance identifier
- `data-focus` - Focus state for dropdown items (true/false)
- Standard data attributes for component state management

### Current Components
- **Modal** - Dialog/popup with overlay (`lib/prima/modal.ex`)
- **Dropdown** - Menu/select functionality (`lib/prima/dropdown.ex`)
- **Combobox** - Searchable input with suggestions (`lib/prima/combobox.ex`)

## Development Workflow

### Browser-Based Exploration and Debugging

**Playwright MCP is the preferred tool for exploring and debugging the demo application.**

- The development server runs on `http://localhost:4000`
- **Always assume the server is running** - navigate to `localhost:4000` to view components
- If nothing loads or the server isn't running, ask the user how to continue
- Use Playwright MCP tools to:
  - Navigate to demo pages and view components visually
  - Take screenshots to understand current UI state
  - Interact with components (click, hover, type) to test behavior
  - Inspect page snapshots to understand DOM structure
- Prefer Playwright MCP to using curl

**Debugging JavaScript Hooks:**
- Add `console.log()` statements in JavaScript hook files (`assets/js/hooks/*.js`)
- Use Playwright's browser console tools to view console output
- Console logs are very useful for understanding hook behavior and state changes
- Consider adding temporary debug logs when troubleshooting component issues

### Testing Strategy
- **ExUnit tests** for simple component logic and rendering
- **Wallaby tests** for complex UI interactions and components with JavaScript behavior, especially:
  - Modal transitions and overlay behavior
  - Dropdown keyboard navigation and interactions
  - Combobox search and selection behavior
  - Form integration and race conditions

**Important**: Due to the interactive nature of Prima components (heavy JavaScript integration, DOM manipulation, keyboard navigation), prefer Wallaby tests over unit tests for component testing. Components rely on Phoenix LiveView hooks and client-side behavior that can only be properly tested in a browser environment.

### Frontend Build System
- **esbuild** with two configurations:
  - `default` - Demo app development
  - `library` - Library export for distribution
- **Tailwind CSS** with standard data attribute selectors for component states
- Assets are built automatically during development

### Demo Application
- Located in `lib/prima_web/` (excluded from package)
- Structured with sidebar navigation and separate component pages:
  - `/` - Introduction page
  - `/dropdown` - Dropdown component demos
  - `/modal` - Modal component demos
  - `/combobox` - Combobox component demos
  - `/history-modal` - History modal demos
- Serves as development environment and living documentation

## Key Development Considerations

### Component Design Philosophy
- **Unstyled by default** - Minimal CSS, maximum customization
- **Accessibility first** - ARIA attributes, focus management, keyboard navigation
- **Phoenix LiveView native** - Deep integration with LiveView patterns

### JavaScript Integration
- Minimal JavaScript footprint via Phoenix LiveView hooks
- JavaScript hooks handle only essential client-side behavior
- All hooks export to main `assets/js/prima.js` for easy integration

### Library vs Application Code
- Library code: `lib/prima/` (included in package)
- Demo/development code: `lib/prima_web/` (excluded from package)
- Keep library components free of demo-specific dependencies

### Styling Approach
- Standard Tailwind data attribute selectors (e.g., `data-[focus=true]:`) for component state styling
- Components use standard HTML data attributes for state management
- Heroicons integrated for consistent icon usage

## Wallaby Testing Tips
- For hidden elements in Wallaby, use Query.visible(false)
- **Performance optimization**: Avoid `refute_has()` calls as they wait for Wallaby's default 3-second timeout. Use the `assert_missing/2` helper instead:
  ```elixir
  # Usage - fast and semantic:
  |> assert_missing(Query.css("#element[data-focus]"))

  # Instead of slow:
  |> refute_has(Query.css("#element[data-focus]"))  # waits 3000ms
  ```
- **Hook Readiness**: Always wait for Prima hooks to be fully ready before interacting with components to avoid race conditions. Use `visit_fixture` helper which visits
the URL and waits for the component with given ID to initialize before continuing with the test:
  ```elixir
  session
  |> visit_fixture("/some-page", "#my-combobox")
  |> click(Query.css("#my-combobox input"))
  |> assert_has(Query.css("#my-combobox [role=option]"))
  ```

  **Why this is needed**: JavaScript hooks need time to set up event listeners after page load. The `visit_fixture/2` helper waits for the `data-prima-ready="true"` attribute that hooks set when fully initialized.

- **Arrow key navigation**: Use correct Wallaby syntax for arrow keys in tests:
  ```elixir
  # Correct syntax:
  |> send_keys([:down_arrow])
  |> send_keys([:up_arrow])
  |> send_keys([:left_arrow])
  |> send_keys([:right_arrow])

  # Incorrect (doesn't work):
  |> send_keys([:arrow_down])    # Wrong
  |> send_keys([:arrow_up])      # Wrong
  ```
- **JavaScript debugging**: Enable JS console logging in a test by adding `Application.put_env(:wallaby, :js_logger, :stdio)` at the beginning of the test feature. This allows you to see `console.log()` output from JavaScript hooks during test execution. More convenient than modifying config files:
  ```elixir
  feature "my test with logging", %{session: session} do
    Application.put_env(:wallaby, :js_logger, :stdio)

    session
    |> visit("/some-page")
    # ... rest of test
  end
  ```

## Creating Fixture Tests

Before writing any code, batch read these files in ONE message:
- `lib/prima_web/router.ex`
- `lib/prima_web/live/fixtures_live.ex`
- `lib/prima_web/live/fixtures_live.html.heex`
- A similar existing fixture file

Then create ALL required files in this order:
1. Fixture HTML file (`.html.heex`)
2. Helper functions in `fixtures_live.ex` (if needed)
3. Route in `router.ex`
4. Template entry in `fixtures_live.html.heex`
5. Test file last

This prevents test failures from missing infrastructure.

## Development Guidelines

### Code Comments
- Remember to not add unnecessary comments
- Only add comments to document tricky operations or add additional context
- Pedantic comments are useless
