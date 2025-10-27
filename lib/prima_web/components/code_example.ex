defmodule PrimaWeb.CodeExample do
  @moduledoc false

  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @examples_dir "priv/code_examples"
  @syntax_theme "molokai"
  @code_block_classes "p-4 rounded-b-lg overflow-x-auto text-sm"

  @live_component_modules [
    PrimaWeb.DemoLive.AsyncModalDemo,
    PrimaWeb.DemoLive.FormModalDemo,
    PrimaWeb.DemoLive.AsyncComboboxDemo
  ]

  for module <- @live_component_modules, do: Code.ensure_compiled(module)

  @highlighted_examples (
                          examples_path = Path.join(File.cwd!(), @examples_dir)

                          highlight_file = fn file_path ->
                            relative_path = Path.relative_to(file_path, examples_path)
                            content = File.read!(file_path)

                            language =
                              case Path.extname(file_path) do
                                ".ex" -> "elixir"
                                ".heex" -> "heex"
                              end

                            highlighted_html =
                              Autumn.highlight!(content,
                                language: language,
                                formatter:
                                  {:html_inline,
                                   theme: @syntax_theme, pre_class: @code_block_classes}
                              )

                            {relative_path, %{highlighted: highlighted_html, source: content}}
                          end

                          Path.wildcard(Path.join([examples_path, "**", "*"]))
                          |> Enum.filter(&File.regular?/1)
                          |> Enum.map(highlight_file)
                          |> Map.new()
                        )

  for {file_path, _} <- @highlighted_examples do
    @external_resource Path.join([@examples_dir, file_path])
  end

  attr :file, :string, required: true, doc: "Path to file in priv/code_examples/"
  attr :module, :atom, default: nil, doc: "LiveComponent module to render (for .ex files)"
  attr :id, :string, default: nil, doc: "Optional ID for the code example container"

  attr :rest, :global,
    include: ~w(live_action),
    doc: "Additional assigns passed to rendered content"

  def code_example(assigns) do
    {highlighted_code, source} = get_example_data(assigns)

    assigns =
      assigns
      |> assign(:highlighted_code, highlighted_code)
      |> assign(:source, source)
      |> assign(:is_module_mode, assigns[:module] != nil)

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
          {render_heex_preview(assigns)}
        <% end %>
      </div>

      <div id={"#{@id}-code"} class="hidden">
        {Phoenix.HTML.raw(@highlighted_code)}
      </div>
    </div>
    """
  end

  attr :file, :string, required: true, doc: "Path to file in priv/code_examples/"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def code_block(assigns) do
    highlighted_content = get_highlighted_code_for_block(assigns)
    assigns = assign(assigns, :highlighted_code, highlighted_content)

    ~H"""
    <div class={["prima-code-block", @class]}>
      {Phoenix.HTML.raw(@highlighted_code)}
    </div>
    """
  end

  defp get_highlighted_code_for_block(%{file: file}) do
    @highlighted_examples
    |> Map.fetch!(file)
    |> Map.fetch!(:highlighted)
  end

  defp get_example_data(%{file: file}) do
    example = Map.fetch!(@highlighted_examples, file)
    {example.highlighted, example.source}
  end

  defp render_heex_preview(%{source: source} = assigns) do
    merged_assigns = Map.merge(assigns, Map.get(assigns, :rest, %{}))
    render_heex_content(source, merged_assigns)
  end

  defp render_heex_content(template_string, assigns) do
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
  end
end
