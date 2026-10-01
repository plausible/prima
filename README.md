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

This repository is structured with the library at the root and a demo application in the `demo/` directory.

### Library Development

Install the versions pinned in `.tool-versions` with `mise install` or `asdf install`.
For asdf, add the plugins before installing the versions:

```bash
asdf plugin add erlang
asdf plugin add elixir
asdf plugin add nodejs
asdf plugin add chromedriver https://github.com/mise-plugins/mise-chromedriver.git
asdf install
```

Browser tests also need Google Chrome; the pinned ChromeDriver is selected
automatically by mise or asdf.
Keep Chrome and ChromeDriver on the same major, minor, and build version when
updating either one.

```bash
# From root directory
mise install            # Or: asdf install
mix setup               # Install dependencies and build the library assets
mix hex.build          # Build hex package
```

### Running the Demo Application

```bash
# From demo/ directory
cd demo
mix setup              # Install demo dependencies and build demo assets
mix phx.server         # Start development server
```

Visit `http://localhost:4000` to see all components in action. The demo application automatically reloads when you make changes to library code.

### Testing

```bash
# Full demo test suite (from root; delegates to demo/)
mix test

# Equivalent command from demo/
cd demo
mix test               # Run ExUnit and Wallaby tests
```

The test suite includes both unit tests and comprehensive browser-based integration tests using Wallaby to ensure all interactive behaviors work correctly.
