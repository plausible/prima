defmodule Livekit.CodeBlock do
  @moduledoc """
  A syntax-highlighted code block component using Makeup.

  ## Examples

      <Livekit.CodeBlock.code_block code={@elixir_code} language={:elixir} />

      <Livekit.CodeBlock.code_block code={@html_code} language={:html} />

  ## Attributes

    * `code` - The source code to highlight (required)
    * `language` - The programming language (`:elixir`, `:html`, `:heex`, `:json`, `:diff`)
    * `class` - Additional CSS classes for the container
  """
  use Phoenix.Component
  import Phoenix.HTML

  @doc """
  Renders a syntax-highlighted code block.
  """
  attr :code, :string, required: true, doc: "The source code to highlight"
  attr :language, :atom, default: :elixir, doc: "Programming language for syntax highlighting"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def code_block(assigns) do
    highlighted =
      try do
        case assigns.language do
          :elixir ->
            Makeup.highlight(assigns.code, lexer: Makeup.Lexers.ElixirLexer)

          :html ->
            Makeup.highlight(assigns.code, lexer: Makeup.Lexers.HTMLLexer)

          :heex ->
            Makeup.highlight(assigns.code, lexer: Makeup.Lexers.HTMLLexer)

          e ->
            Logger.error("Unknown language: #{e}")
            escaped_code = assigns.code |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
            ~s(<pre class="highlight"><code>#{escaped_code}</code></pre>)
        end
      rescue
        e ->
          Logger.error("Lexer error: #{e}")
          escaped_code = assigns.code |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
          ~s(<pre class="highlight"><code>#{escaped_code}</code></pre>)
      end

    assigns = assign(assigns, :highlighted_code, highlighted)

    ~H"""
    <div class={["livekit-code-block", @class]}>
      <%= raw(@highlighted_code) %>
    </div>
    """
  end
end
