# 🧩 Single-Repo Library with Internal Demo App (No Umbrella)

This setup places your **library** at the root of the repository (publishable to Hex)  
and keeps a **demo / showcase app** in a `demo/` subfolder.

It’s clean for open source projects — users see the library at the top level,  
while maintainers get a full demo and release pipeline with live reloads.

---

## 🗂️ Folder Structure

```
repo-root/
  mix.exs                 # <- main library project
  lib/
  test/
  README.md
  LICENSE
  .formatter.exs
  CHANGELOG.md

  demo/                   # internal demo app; not published
    mix.exs
    lib/
      demo/application.ex
      demo_web/...
    config/
      config.exs
      dev.exs
      prod.exs
      runtime.exs
    priv/static/...
    assets/...
```

---

## ⚙️ Root `mix.exs` — The Library Project

```elixir
defmodule MyLib.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_lib,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Core library for …",
      package: [
        licenses: ["MIT"],
        links: %{"GitHub" => "https://…"},
        files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md)
      ]
    ]
  end

  # No :mod key → library does NOT auto-start as a dependency
  def application, do: [extra_applications: [:logger]]

  def deps do
    [
      # Keep minimal, library-safe dependencies only
      # {:plug, "~> 1.15", optional: true}
    ]
  end
end
```

**Notes**
- This is the project you publish to Hex.
- No supervision tree or side effects → safe for use as dependency.
- Demo deps live **only** in `demo/mix.exs`.

---

## ⚙️ `demo/mix.exs` — The Demo / Release Project

```elixir
defmodule Demo.MixProject do
  use Mix.Project

  def project do
    [
      app: :demo,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        demo: [
          applications: [
            demo: :permanent,
            my_lib: :permanent
          ]
        ]
      ]
    ]
  end

  # This app DOES start an OTP supervision tree
  def application do
    [
      mod: {Demo.Application, []},
      extra_applications: [:logger]
    ]
  end

  def deps do
    [
      # Use the library from repo root
      {:my_lib, path: ".."},

      # Demo-only deps
      {:phoenix, "~> 1.7"},
      {:phoenix_pubsub, "~> 2.1"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_view, "~> 1.0"},
      {:plug_cowboy, "~> 2.7"},

      # Dev/test tooling
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.2", only: :dev, runtime: false}
    ]
  end
end
```

---

## 🧠 `demo/lib/demo/application.ex`

```elixir
defmodule Demo.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # e.g. DemoWeb.Endpoint,
      # and processes using MyLib
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Demo.Supervisor)
  end
end
```

---

## 🔁 Auto-Reloading Setup

### A) Mix recompilation (built-in)
Because `{:my_lib, path: ".."}` is a **path dependency**, Mix automatically:
- tracks file mtimes in `../lib/`
- recompiles `:my_lib` whenever a source file changes

You’ll see logs like:
```
[info] Recompiling dependency :my_lib
```

This happens automatically in `MIX_ENV=dev`.

### B) Phoenix live reload (browser refresh)
Add your library path to `live_reload.patterns` in `demo/config/dev.exs`:

```elixir
import Config

config :demo, DemoWeb.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/demo_web/(live|views)/.*(ex)$",
      ~r"lib/demo_web/templates/.*(eex|heex)$",
      # Watch the parent library too 👇
      ~r"../lib/.*(ex)$"
    ]
  ]
```

### C) Optional — compile library directly (fastest dev reloads)
In `demo/mix.exs`:

```elixir
defp elixirc_paths(:dev), do: ["lib", "../lib"]
defp elixirc_paths(_), do: ["lib"]
```

- **Pros:** fastest edit–reload loop (single compile pass)  
- **Cons:** library not isolated as dependency (don’t use in production)

---

## 🧪 Development Workflow

From `repo-root/demo`:

```bash
# Install dependencies
mix deps.get

# Start the demo app
mix phx.server   # or iex -S mix if non-Phoenix
```

Then edit:
- `lib/**` → library changes
- `demo/lib/**` → demo app changes

✅ Mix recompiles on save  
✅ Phoenix CodeReloader reloads modules  
✅ Browser refreshes automatically

---

## 🚀 Building a Release

From `repo-root/demo`:

```bash
MIX_ENV=prod mix deps.get
MIX_ENV=prod mix compile
# If Phoenix
MIX_ENV=prod mix assets.deploy

MIX_ENV=prod mix release demo
_build/prod/rel/demo/bin/demo start
```

The release bundles:
- `:demo` OTP app (booted)
- `:my_lib` (compiled in as dependency)

---

## 📦 Publishing to Hex (library only)

From the repo root:

```bash
mix hex.build
mix hex.publish
```

`package.files` ensures `demo/` is **excluded** from the Hex tarball.

---

## ⚠️ Tips & Gotchas

| Tip | Why |
|-----|-----|
| No `:mod` in `application/0` | Prevents auto-start when used as a dependency |
| Keep demo deps out of root `mix.exs` | Keeps Hex package lean |
| Add `../lib` to `live_reload.patterns` | Enables browser refresh on library edits |
| Test both independently | `mix test` in each folder |
| CI: run `mix hex.build` (root) and `mix release` (demo) | Keeps both healthy |

---

## ✅ Summary

| Goal | Achieved by |
|------|--------------|
| Library at repo root | Top-level `mix.exs` |
| Demo app separate | In `demo/` folder with its own Mix project |
| Auto-recompile on edits | Path dependency (`path: ".."`) |
| Browser auto-refresh | Phoenix `live_reload` watching `../lib` |
| Clean Hex package | Restrictive `package.files` |
| No umbrella | Two standalone Mix projects |
| Production-ready releases | Build from `demo/` |

---

You now have a **single-repo, no-umbrella** structure that:  
✅ keeps your library clean and publishable,  
✅ includes a demo for experimentation and releases, and  
✅ supports auto-reload during local development.
