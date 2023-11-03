defmodule Livekit do
  @moduledoc """
  Livekit keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defdelegate modal(assigns), to: Livekit.Modal
  defdelegate modal_overlay(assigns), to: Livekit.Modal
  defdelegate modal_panel(assigns), to: Livekit.Modal
end
