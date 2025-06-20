defmodule Livekit do
  @moduledoc """
  Livekit is a Phoenix LiveView component library providing unstyled, accessible UI components.

  Livekit is designed as a reusable library that developers can integrate into Phoenix
  applications and style according to their needs. The library follows a philosophy of
  being unstyled by default with maximum customization potential, accessibility-first
  design, and deep Phoenix LiveView integration.

  ## Design Philosophy

  - **Unstyled by default** - Minimal CSS, maximum customization
  - **Accessibility first** - ARIA attributes, focus management, keyboard navigation
  - **Phoenix LiveView native** - Deep integration with LiveView patterns

  ## Available Components

  Livekit currently provides the following components:

  ### Modal
  A fully-managed dialog component with accessibility features and smooth transitions.
  Supports async loading, form integration, and browser history integration.

      <.modal id="my-modal">
        <.modal_overlay class="fixed inset-0 bg-gray-500/75" />
        <.modal_panel id="my-panel" class="bg-white rounded-lg">
          <p>Modal content</p>
        </.modal_panel>
      </.modal>

  ### Dropdown
  Menu and select functionality with keyboard navigation and customizable positioning.

  ### Combobox
  Searchable input component with suggestions and autocomplete functionality.

  ## Architecture

  Each component follows a three-layer pattern:

  1. **Phoenix Component** (`lib/livekit/*.ex`) - Server-side rendering and LiveView integration
  2. **JavaScript Hook** (`assets/js/hooks/*.js`) - Client-side behavior and DOM manipulation
  3. **CSS Integration** - Tailwind-based styling with custom `livekit` plugin

  ## Getting Started

  Add Livekit to your Phoenix application:

      {:livekit, "~> 0.1.0"}

  Include the JavaScript hooks in your application:

      import { LivekitHooks } from "livekit"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: LivekitHooks,
        // ... other options
      })
  """
end
