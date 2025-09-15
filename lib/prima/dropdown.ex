defmodule Prima.Dropdown do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :id, :string, default: ""
  slot :inner_block, required: true

  def dropdown(assigns) do
    ~H"""
    <div id={@id} phx-hook="Dropdown" phx-click-away={JS.dispatch("prima:close")}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  attr :as, :any, default: nil
  slot :inner_block, required: true

  def dropdown_trigger(assigns) do
    assigns =
      assign(assigns, %{
        "aria-haspopup": "menu",
        "aria-expanded": "false"
      })

    if assigns[:as] do
      {as, assigns} = Map.pop(assigns, :as)
      as.(assigns)
    else
      dynamic_tag(
        Map.merge(assigns, %{
          tag_name: "button",
          type: "button"
        })
      )
    end
  end

  attr :transition_enter, :any, default: nil
  attr :transition_leave, :any, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def dropdown_menu(assigns) do
    ~H"""
    <div
      class={@class}
      style="display: none"
      js-toggle={JS.toggle(in: @transition_enter, out: @transition_leave)}
      js-hide={JS.hide(transition: @transition_leave)}
      role="menu"
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  slot :inner_block, required: true

  def dropdown_item(assigns) do
    ~H"""
    <div class={@class} role="menuitem" tabindex="-1">
      {render_slot(@inner_block)}
    </div>
    """
  end
end
