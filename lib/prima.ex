defmodule Prima do
  @moduledoc """
  Prima is a Phoenix LiveView component library providing unstyled, accessible UI components.

  Prima is designed as a reusable library that developers can integrate into Phoenix
  applications and style according to their needs. The library follows a philosophy of
  being unstyled by default with maximum customization potential, accessibility-first
  design, and deep Phoenix LiveView integration.

  ## Design Philosophy

  - **Unstyled by default** - Minimal CSS, maximum customization
  - **Accessibility first** - ARIA attributes, focus management, keyboard navigation
  - **Phoenix LiveView native** - Deep integration with LiveView patterns

  ## Getting Started

  Add Prima to your Phoenix application:

      {:prima, "~> 0.1.0"}

  Include the JavaScript hooks in your application:

      import { PrimaHooks } from "prima"

      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: PrimaHooks,
        // ... other options
      })
  """
end
