defmodule Livekit.Dropdown do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  slot :id, required: true
  slot :inner_block, required: true

  def dropdown(assigns) do
    ~H"""
    <div id={@id} phx-hook="Dropdown">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  slot :inner_block, required: true

  def dropdown_button(assigns) do
    ~H"""
    <button type="button" aria-haspopup="menu">
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  slot :inner_block, required: true

  def dropdown_items(assigns) do
    ~H"""
    <div style="display: none" js-open={JS.toggle()} role="menu">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  slot :inner_block, required: true

  def dropdown_item(assigns) do
    ~H"""
    <div role="menuitem">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
