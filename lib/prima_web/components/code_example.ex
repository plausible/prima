defmodule PrimaWeb.CodeExample do
  @moduledoc """
  A component for displaying live demos alongside their source code.

  Renders the component example in a tabbed interface with Preview and Code views.
  The component can either render provided content via inner_block or dynamically
  render HEEx templates from files.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :file, :string, required: true, doc: "Path to file in priv/code_examples/"

  @doc """
  Displays a live demo alongside syntax-highlighted source code.

  Renders the component example with a tabbed interface for switching between
  Preview and Code views. The source code is loaded from a file in priv/code_examples/
  and automatically rendered in the preview.

  ## Example

      <.code_example file="dropdown/basic_dropdown.heex" />
  """
  def code_example(assigns) do
    source = get_code_source(assigns)
    assigns = assign(assigns, :highlighted_code, highlight_code(source))
    assigns = assign(assigns, :rendered_content, render_heex_content(source, assigns))
    id = assigns[:id] || "code-example-#{:erlang.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)

    ~H"""
    <div class="relative border border-gray-200 rounded-lg bg-white" id={@id}>
      <div class="flex items-center justify-between border-b border-gray-200 rounded-t-lg px-4 py-2 bg-gray-50">
        <div class="flex gap-2">
          <button
            type="button"
            phx-click={
              JS.add_class("hidden", to: "##{@id}-code")
              |> JS.remove_class("hidden", to: "##{@id}-preview")
              |> JS.add_class("bg-white border-gray-300 text-gray-900", to: "##{@id}-preview-tab")
              |> JS.remove_class("bg-white border-gray-300 text-gray-900", to: "##{@id}-code-tab")
              |> JS.add_class("bg-gray-50 border-transparent text-gray-600", to: "##{@id}-code-tab")
              |> JS.remove_class("bg-gray-50 border-transparent text-gray-600",
                to: "##{@id}-preview-tab"
              )
            }
            id={"#{@id}-preview-tab"}
            class="px-3 py-1.5 text-sm font-medium rounded border bg-white border-gray-300 text-gray-900 transition-colors"
          >
            Preview
          </button>
          <button
            type="button"
            phx-click={
              JS.add_class("hidden", to: "##{@id}-preview")
              |> JS.remove_class("hidden", to: "##{@id}-code")
              |> JS.add_class("bg-white border-gray-300 text-gray-900", to: "##{@id}-code-tab")
              |> JS.remove_class("bg-white border-gray-300 text-gray-900", to: "##{@id}-preview-tab")
              |> JS.add_class("bg-gray-50 border-transparent text-gray-600",
                to: "##{@id}-preview-tab"
              )
              |> JS.remove_class("bg-gray-50 border-transparent text-gray-600",
                to: "##{@id}-code-tab"
              )
            }
            id={"#{@id}-code-tab"}
            class="px-3 py-1.5 text-sm font-medium rounded border bg-gray-50 border-transparent text-gray-600 transition-colors"
          >
            Code
          </button>
        </div>
      </div>

      <div id={"#{@id}-preview"} class="p-6">
        {Phoenix.HTML.raw(@rendered_content)}
      </div>

      <div id={"#{@id}-code"} class="hidden">
        <!-- <div class="p-4 bg-gray-900 rounded-b-lg overflow-x-auto text-sm"> -->
        {Phoenix.HTML.raw(@highlighted_code)}
        <!-- </div> -->
      </div>
    </div>
    """
  end

  defp get_code_source(%{file: file}) when is_binary(file) do
    file_path = Path.join(["priv", "code_examples", file])

    case File.read(file_path) do
      {:ok, content} -> content
      {:error, _} -> "Error: Could not read file '#{file}'"
    end
  end

  defp highlight_code(source) do
    source
    |> String.trim()
    |> Autumn.highlight!(
      language: "heex",
      formatter:
        {:html_inline, theme: "molokai", pre_class: "p-4 rounded-b-lg overflow-x-auto text-sm"}
    )
  end

  defp render_heex_content(template_string, assigns) do
    try do
      # Compile and evaluate the HEEx template with component imports
      {result, _} =
        Code.eval_string(
          """
          import Phoenix.Component
          import Prima.Modal
          import Prima.Dropdown
          import Prima.Combobox
          import PrimaWeb.CoreComponents

          ~H\"\"\"
          #{template_string}
          \"\"\"
          """,
          assigns: assigns
        )

      {:safe, result}
    rescue
      e ->
        "<div class='text-red-600 p-4'>Error rendering template: #{Exception.message(e)}</div>"
    end
  end
end
