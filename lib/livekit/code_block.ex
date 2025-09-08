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
                       ".ex" -> :elixir
                       ".exs" -> :elixir
                       ".heex" -> :heex
                       ".html" -> :html
                       ".htm" -> :html
                       _ -> :elixir
                     end
                   end

                   highlight_code = fn content, language ->
                     try do
                       case language do
                         :elixir ->
                           Makeup.highlight(content, lexer: Makeup.Lexers.ElixirLexer)

                         :html ->
                           Makeup.highlight(content, lexer: Makeup.Lexers.HTMLLexer)

                         :heex ->
                           Makeup.highlight(content, lexer: Makeup.Lexers.HTMLLexer)

                         _ ->
                           escaped_code =
                             content
                             |> Phoenix.HTML.html_escape()
                             |> Phoenix.HTML.safe_to_string()

                           ~s(<pre class="highlight"><code>#{escaped_code}</code></pre>)
                       end
                     rescue
                       _e ->
                         escaped_code =
                           content |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()

                         ~s(<pre class="highlight"><code>#{escaped_code}</code></pre>)
                     end
                   end

                   if File.exists?(examples_path) do
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
                   else
                     %{}
                   end
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
    <div class={["livekit-code-block", @class]}>
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

  @doc """
  Returns a list of all available code example files.

  Useful for development and debugging.
  """
  def list_examples do
    Map.keys(@code_examples)
    |> Enum.sort()
  end
end
