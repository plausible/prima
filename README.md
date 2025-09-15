# Prima

[![Hex.pm](https://img.shields.io/hexpm/v/prima.svg)](https://hex.pm/packages/prima)

> **prima** (adj., Latin)
>
> First; primary.
> – Used in alchemical texts denoting the original, undifferentiated substance from which all things are formed and upon which the alchemical work is based.

Prima is a Phoenix LiveView component library providing unstyled, accessible UI components. It's designed as a reusable library that developers can integrate into Phoenix applications and style according to their needs.

## Installation

Add `prima` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prima, "~> 0.1.0"}
  ]
end
```

Include Prima's JavaScript hooks in your application:

```javascript
// assets/js/app.js
import { PrimaHooks } from "prima"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...PrimaHooks },
  // ... other options
})
```

Use components in your templates:

```heex
<Prima.Dropdown.dropdown id="demo-dropdown">
  <Prima.Dropdown.dropdown_trigger>
    Open Dropdown
  </Prima.Dropdown.dropdown_trigger>

  <Prima.Dropdown.dropdown_menu>
    <Prima.Dropdown.dropdown_item>Item 1</.dropdown_item>
    <Prima.Dropdown.dropdown_item>Item 2</.dropdown_item>
  </Prima.Dropdown.dropdown_menu>
</Prima.Dropdown.dropdown>
```

## Development

### Setup

```bash
mix setup                # Full setup (deps, assets setup, assets build)
```

### Running the Demo

```bash
mix phx.server          # Start development server
```

Visit `http://localhost:4000/demo` to see all components in action.

### Testing

```bash
mix test               # Run all tests (includes ExUnit and Wallaby tests)
```

The test suite includes both unit tests and comprehensive browser-based integration tests using Wallaby to ensure all interactive behaviors work correctly.
