defmodule Prima.WallabyCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature
      import Prima.WallabyTestHelpers
    end
  end
end
