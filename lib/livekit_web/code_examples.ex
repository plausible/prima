defmodule LivekitWeb.CodeExamples do
  @moduledoc """
  Provides code examples for the demo application.
  Files are read at compile-time for better performance.
  """

  @examples_dir "priv/code_examples"

  @modal_basic_modal Path.join([@examples_dir, "modal", "basic_modal.heex"]) |> File.read!()
  @modal_form_modal_events Path.join([@examples_dir, "modal", "form_modal_events.ex"]) |> File.read!()
  @modal_form_modal_template Path.join([@examples_dir, "modal", "form_modal_template.heex"]) |> File.read!()
  @modal_history_routes Path.join([@examples_dir, "modal", "history_routes.ex"]) |> File.read!()

  def modal_basic_modal, do: @modal_basic_modal
  def modal_form_modal_events, do: @modal_form_modal_events
  def modal_form_modal_template, do: @modal_form_modal_template
  def modal_history_routes, do: @modal_history_routes
end
