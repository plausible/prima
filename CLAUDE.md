# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Livekit is a Phoenix LiveView component library providing unstyled, accessible UI components. It's designed as a reusable library that developers can integrate into Phoenix applications and style according to their needs.

## Essential Commands

### Setup & Dependencies
```bash
mix setup                # Full setup (deps, assets setup, assets build)
mix deps.get            # Get Elixir dependencies
mix assets.setup        # Install Tailwind and esbuild
```

### Development
```bash
mix phx.server          # Start development server (demo app at localhost:4000)
mix assets.build        # Build assets for development
```

### Testing
```bash
mix test                # Run ExUnit tests (includes esbuild default build)
```

For Wallaby browser tests specifically:
- Tests are in `test/wallaby/livekit_web/`
- ChromeDriver-based integration tests for UI interactions
- Run with standard `mix test` command

### Build & Deploy
```bash
mix assets.deploy       # Minified production build with digest
```

## Architecture & Component Patterns

### Core Architecture
The library follows a three-layer pattern for each component:
1. **Phoenix Component** (`lib/livekit/*.ex`) - Server-side rendering and LiveView integration
2. **JavaScript Hook** (`assets/js/hooks/*.js`) - Client-side behavior and DOM manipulation  
3. **CSS Integration** - Tailwind-based styling with custom `livekit` plugin

### Component Structure
```elixir
# Standard component pattern
defmodule Livekit.ComponentName do
  use Phoenix.Component
  
  # Main component function with slots and attributes
  attr :id, :string, required: true
  slot :inner_block, required: true
  def component_name(assigns) do
    ~H"""
    <div phx-hook="ComponentName" livekit-ref={@id}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
```

### Custom Data Attributes
- `livekit-ref` - Component instance identifier
- `livekit-state` - Component state for CSS variants
- Used by Tailwind plugin for state-based styling variants

### Current Components
- **Modal** - Dialog/popup with overlay (`lib/livekit/modal.ex`)
- **Dropdown** - Menu/select functionality (`lib/livekit/dropdown.ex`)
- **Combobox** - Searchable input with suggestions (`lib/livekit/combobox.ex`)

## Development Workflow

### Testing Strategy
- **ExUnit tests** for simple component logic and rendering
- **Wallaby tests** for complex UI interactions and components with JavaScript behavior, especially:
  - Modal transitions and overlay behavior  
  - Dropdown keyboard navigation and interactions
  - Combobox search and selection behavior
  - Form integration and race conditions
  
**Important**: Due to the interactive nature of Livekit components (heavy JavaScript integration, DOM manipulation, keyboard navigation), prefer Wallaby tests over unit tests for component testing. Components rely on Phoenix LiveView hooks and client-side behavior that can only be properly tested in a browser environment.

### Frontend Build System
- **esbuild** with two configurations:
  - `default` - Demo app development
  - `library` - Library export for distribution
- **Tailwind CSS** with custom `livekit` plugin for component states
- Assets are built automatically during development

### Demo Application
- Located in `lib/livekit_web/` (excluded from package)
- Structured with sidebar navigation and separate component pages:
  - `/demo` - Introduction page
  - `/demo/dropdown` - Dropdown component demos
  - `/demo/modal` - Modal component demos  
  - `/demo/combobox` - Combobox component demos
  - `/demo/history-modal` - History modal demos
- Serves as development environment and living documentation

## Key Development Considerations

### Component Design Philosophy
- **Unstyled by default** - Minimal CSS, maximum customization
- **Accessibility first** - ARIA attributes, focus management, keyboard navigation
- **Phoenix LiveView native** - Deep integration with LiveView patterns

### JavaScript Integration
- Minimal JavaScript footprint via Phoenix LiveView hooks
- JavaScript hooks handle only essential client-side behavior
- All hooks export to main `assets/js/livekit.js` for easy integration

### Library vs Application Code
- Library code: `lib/livekit/` (included in package)
- Demo/development code: `lib/livekit_web/` (excluded from package)
- Keep library components free of demo-specific dependencies

### Styling Approach
- Custom Tailwind plugin provides `livekit-active` and `livekit-not-active` variants
- Components use `livekit-state` attribute to trigger CSS state changes
- Heroicons integrated for consistent icon usage

## Wallaby Testing Tips
- For hidden elements in Wallaby, use Query.visible(false)