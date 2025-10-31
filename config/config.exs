# This file is responsible for configuring your library
# and its dependencies with the aid of the Config module.

import Config

# Configure esbuild for library build
config :esbuild,
  version: "0.17.11",
  library: [
    args: ~w(js/prima.js --bundle --format=esm --target=es2017 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]
