defmodule Livekit.CodeBlock do
  @moduledoc false
  use Phoenix.Component
  import Phoenix.HTML
  require Logger

  @examples_dir "priv/code_examples"

  # Automatically discover and load all code example files at compile-time with syntax highlighting
  @code_examples (
                   examples_path = Path.join(File.cwd!(), @examples_dir)

                   detect_language = fn file_path ->
                     case Path.extname(file_path) do
                       ".ex" -> "elixir"
                       ".heex" -> "heex"
                     end
                   end

                   highlight_code = fn content, language ->
                    Autumn.highlight!(content, language: language, formatter: {:html_inline, theme: "molokai"})
                   end

                     Path.wildcard(Path.join([examples_path, "**", "*"]))
                     |> Enum.filter(&File.regular?/1)
                     |> Enum.map(fn file_path ->
                       relative_path = Path.relative_to(file_path, examples_path)
                       content = File.read!(file_path)
                       language = detect_language.(relative_path)
                       highlighted_content = highlight_code.(content, language)
                       {relative_path, highlighted_content}
                     end)
                     |> Map.new()
                 )

  # Add external resources for automatic recompilation during development
  for {file_path, _content} <- @code_examples do
    @external_resource Path.join([@examples_dir, file_path])
  end

  @doc """
  Renders a syntax-highlighted code block from a file in priv/code_examples/.

  Syntax highlighting is performed at compile-time for optimal runtime performance.
  """
  attr :file, :string, required: true, doc: "Path to file in priv/code_examples/"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def code_block(assigns) do
    highlighted_content = get_highlighted_content(assigns)
    assigns = assign(assigns, :highlighted_code, highlighted_content)

    ~H"""
    <div class={["livekit-code-block", "text-sm", @class]}>
      {raw(@highlighted_code)}
    </div>
    """
  end

  defp get_highlighted_content(assigns) do
    case Map.get(@code_examples, assigns.file) do
      nil ->
        escaped_error =
          "Error: Code example file '#{assigns.file}' not found in #{@examples_dir}"
          |> Phoenix.HTML.html_escape()
          |> Phoenix.HTML.safe_to_string()

        ~s(<pre class="highlight"><code>#{escaped_error}</code></pre>)

      highlighted_content ->
        highlighted_content
    end
  end
end
