defmodule Mix.Tasks.WatchLibrary do
  @moduledoc "Watches library JavaScript files and rebuilds bundle on changes"
  use Mix.Task

  @shortdoc "Watch and rebuild library assets"
  def run(_args) do
    assets_dir = Path.expand("../../../../assets", __DIR__)

    {_result, exit_code} =
      System.cmd(
        Esbuild.bin_path(),
        [
          "js/prima.js",
          "--bundle",
          "--format=esm",
          "--target=es2017",
          "--outdir=../priv/static/assets",
          "--watch",
          "--sourcemap=inline"
        ],
        cd: assets_dir,
        into: IO.stream(:stdio, :line),
        stderr_to_stdout: true
      )

    System.halt(exit_code)
  end
end
