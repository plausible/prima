defmodule Mix.Tasks.WatchLibrary do
  @moduledoc "Watches library JavaScript files and rebuilds bundle on changes"
  use Mix.Task

  @shortdoc "Watch and rebuild library assets"
  def run(_args) do
    # Run esbuild watch from parent directory
    {_result, exit_code} =
      System.cmd(
        "sh",
        [
          "-c",
          "cd .. && npx esbuild assets/js/prima.js --bundle --format=esm --target=es2017 --outdir=priv/static/assets --watch --sourcemap=inline"
        ],
        into: IO.stream(:stdio, :line),
        stderr_to_stdout: true
      )

    System.halt(exit_code)
  end
end
