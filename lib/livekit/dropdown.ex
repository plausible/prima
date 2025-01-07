defmodule Livekit.Dropdown do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :id, :string, default: ""
  slot :inner_block, required: true

  # TODO: phx-click-away ID is hardcoded
  def dropdown(assigns) do
    ~H"""
    <div id={@id} phx-hook="Dropdown" phx-click-away={JS.exec("js-hide", to: "#dropdown-items")}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  slot :inner_block, required: true

  def dropdown_button(assigns) do
    ~H"""
    <button class={@class} type="button" aria-haspopup="menu">
      {render_slot(@inner_block)}
    </button>
    """
  end

  attr :transition_enter, :any, default: {}
  attr :transition_leave, :any, default: {}
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def dropdown_items(assigns) do
    ~H"""
    <div
      class={@class}
      style="display: none"
      js-toggle={JS.toggle(in: @transition_enter, out: @transition_leave)}
      js-hide={JS.hide(transition: @transition_leave)}
      role="menu"
      id="dropdown-items"
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  slot :inner_block, required: true

  def dropdown_item(assigns) do
    ~H"""
    <div class={@class} role="menuitem" livekit-state="">
      {render_slot(@inner_block)}
    </div>
    """
  end
end
