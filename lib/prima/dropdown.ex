defmodule Prima.Dropdown do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :id, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def dropdown(assigns) do
    ~H"""
    <div id={@id} phx-hook="Dropdown" {@rest}>
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

  # Positioning reference
  attr :reference, :string, default: nil

  # Floating UI positioning options
  attr :placement, :string,
    default: "bottom-start",
    values:
      ~w(top top-start top-end right right-start right-end bottom bottom-start bottom-end left left-start left-end)

  attr :flip, :boolean, default: true
  attr :offset, :integer, default: 4

  def dropdown_menu(assigns) do
    ~H"""
    <div
      style="display: none; position: absolute; top: 0; left: 0;"
      data-prima-ref="menu-wrapper"
      data-reference={@reference}
      data-placement={@placement}
      data-flip={@flip}
      data-offset={@offset}
    >
      <div
        class={@class}
        style="display: none;"
        js-show={JS.show(transition: @transition_enter)}
        js-hide={JS.hide(transition: @transition_leave)}
        role="menu"
        phx-click-away={JS.dispatch("prima:close")}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :class, :string, default: ""
  attr :disabled, :boolean, default: false
  slot :inner_block, required: true

  def dropdown_item(assigns) do
    assigns = assign(assigns, :aria_disabled, if(assigns.disabled, do: "true", else: nil))
    assigns = assign(assigns, :data_disabled, if(assigns.disabled, do: "true", else: nil))

    ~H"""
    <div
      class={@class}
      role="menuitem"
      tabindex="-1"
      aria-disabled={@aria_disabled}
      data-disabled={@data_disabled}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
