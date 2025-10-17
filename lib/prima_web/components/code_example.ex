defmodule PrimaWeb.CodeExample do
  @moduledoc """
  A component for displaying live demos alongside their source code.

  Renders the component example in a tabbed interface with Preview and Code views.
  The component can either render provided content via inner_block or dynamically
  render HEEx templates from files.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :file, :string, default: nil, doc: "Path to file in priv/code_examples/"
  attr :module, :atom, default: nil, doc: "LiveComponent module to render"
  attr :id, :string, default: nil, doc: "Optional ID for the code example container"

  @doc """
  Displays a live demo alongside syntax-highlighted source code.

  Renders the component example with a tabbed interface for switching between
  Preview and Code views. Supports two modes:

  - **File mode**: Load HEEx template from priv/code_examples/ and render it
  - **Module mode**: Render a LiveComponent and show its source code

  ## Examples

      # HEEx template example
      <.code_example file="dropdown/basic_dropdown.heex" />

      # LiveComponent example
      <.code_example module={PrimaWeb.DemoLive.AsyncModalDemo} id="async-modal-demo" />
  """
  def code_example(assigns) do
    {source, language} = get_code_source_and_language(assigns)
    assigns = assign(assigns, :highlighted_code, highlight_code(source, language))
    assigns = assign(assigns, :rendered_content, render_content(assigns))
    assigns = assign(assigns, :is_module_mode, assigns[:module] != nil)
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
        <%= if @is_module_mode do %>
          <.live_component module={@module} id={@id <> "-component"} />
        <% else %>
          {Phoenix.HTML.raw(@rendered_content)}
        <% end %>
      </div>

      <div id={"#{@id}-code"} class="hidden">
        <!-- <div class="p-4 bg-gray-900 rounded-b-lg overflow-x-auto text-sm"> -->
        {Phoenix.HTML.raw(@highlighted_code)}
        <!-- </div> -->
      </div>
    </div>
    """
  end

  defp get_code_source_and_language(%{module: module})
       when is_atom(module) and not is_nil(module) do
    source = get_module_source(module)
    {source, "elixir"}
  end

  defp get_code_source_and_language(%{file: file}) when is_binary(file) do
    source = get_file_source(file)
    {source, "heex"}
  end

  defp get_code_source_and_language(_assigns) do
    {"Error: Must provide either 'file' or 'module' attribute", "text"}
  end

  defp get_file_source(file) do
    file_path = Path.join(["priv", "code_examples", file])

    case File.read(file_path) do
      {:ok, content} -> content
      {:error, _} -> "Error: Could not read file '#{file}'"
    end
  end

  defp get_module_source(module) do
    # Try to get the source file from module compilation info
    case Code.fetch_docs(module) do
      {:docs_v1, _, _, _, _, _, _} ->
        # Module is compiled, try to get source from module info
        case module.module_info(:compile)[:source] do
          source when is_list(source) ->
            source_path = List.to_string(source)

            case File.read(source_path) do
              {:ok, content} -> content
              {:error, _} -> fallback_module_source(module)
            end

          _ ->
            fallback_module_source(module)
        end

      {:error, _} ->
        fallback_module_source(module)
    end
  end

  defp fallback_module_source(module) do
    # Fallback: Convert module name to file path
    # e.g., PrimaWeb.DemoLive.AsyncModalDemo -> prima_web/live/demo_live/async_modal_demo
    module_path =
      module
      |> Module.split()
      |> Enum.map(&Macro.underscore/1)
      |> Enum.join("/")

    # Try common locations
    potential_paths = [
      "lib/#{module_path}.ex",
      "#{module_path}.ex"
    ]

    case Enum.find_value(potential_paths, fn path ->
           case File.read(path) do
             {:ok, content} -> content
             {:error, _} -> nil
           end
         end) do
      nil ->
        "Error: Could not read source for module '#{inspect(module)}' (tried: #{Enum.join(potential_paths, ", ")})"

      content ->
        content
    end
  end

  defp highlight_code(source, language) do
    source
    |> String.trim()
    |> Autumn.highlight!(
      language: language,
      formatter:
        {:html_inline, theme: "molokai", pre_class: "p-4 rounded-b-lg overflow-x-auto text-sm"}
    )
  end

  defp render_content(%{module: module}) when is_atom(module) and not is_nil(module) do
    # For module mode, we render the live_component directly in the template
    # so we don't need to return content here
    ""
  end

  defp render_content(%{file: file} = assigns) when is_binary(file) do
    source = get_file_source(file)
    render_heex_content(source, assigns)
  end

  defp render_content(_assigns) do
    "<div class='text-red-600 p-4'>Error: Must provide either 'file' or 'module' attribute</div>"
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
          alias Phoenix.LiveView.JS

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
