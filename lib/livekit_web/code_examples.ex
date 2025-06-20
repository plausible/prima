defmodule LivekitWeb.CodeExamples do
  @moduledoc """
  Provides syntax-highlighted code examples for the demo application.
  Files are read at compile-time and highlighted using Makeup.
  """
  use Phoenix.Component

  @examples_dir "priv/code_examples"

  # External resources for automatic recompilation during development
  @external_resource Path.join([@examples_dir, "modal", "minimal_modal.heex"])
  @external_resource Path.join([@examples_dir, "modal", "basic_modal.heex"])
  @external_resource Path.join([@examples_dir, "modal", "form_modal_events.ex"])
  @external_resource Path.join([@examples_dir, "modal", "form_modal_template.heex"])
  @external_resource Path.join([@examples_dir, "modal", "history_routes.ex"])

  @modal_minimal_modal Path.join([@examples_dir, "modal", "minimal_modal.heex"]) |> File.read!()
  @modal_basic_modal Path.join([@examples_dir, "modal", "basic_modal.heex"]) |> File.read!()
  @modal_form_modal_events Path.join([@examples_dir, "modal", "form_modal_events.ex"]) |> File.read!()
  @modal_form_modal_template Path.join([@examples_dir, "modal", "form_modal_template.heex"]) |> File.read!()
  @modal_history_routes Path.join([@examples_dir, "modal", "history_routes.ex"]) |> File.read!()

  def modal_minimal_modal(assigns \\ %{}) do
    assigns = assign(assigns, :code, @modal_minimal_modal)
    
    ~H"""
    <Livekit.CodeBlock.code_block code={@code} language={:heex} />
    """
  end

  def modal_basic_modal(assigns \\ %{}) do
    assigns = assign(assigns, :code, @modal_basic_modal)
    
    ~H"""
    <Livekit.CodeBlock.code_block code={@code} language={:heex} />
    """
  end

  def modal_form_modal_events(assigns \\ %{}) do
    assigns = assign(assigns, :code, @modal_form_modal_events)
    
    ~H"""
    <Livekit.CodeBlock.code_block code={@code} language={:heex} />
    """
  end

  def modal_form_modal_template(assigns \\ %{}) do
    assigns = assign(assigns, :code, @modal_form_modal_template)
    
    ~H"""
    <Livekit.CodeBlock.code_block code={@code} language={:heex} />
    """
  end

  def modal_history_routes(assigns \\ %{}) do
    assigns = assign(assigns, :code, @modal_history_routes)
    
    ~H"""
    <Livekit.CodeBlock.code_block code={@code} language={:elixir} />
    """
  end
end
