defmodule Livekit.Combobox do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :id, :string, default: ""
  slot :inner_block, required: true
  attr :class, :string, default: ""

  def combobox(assigns) do
    ~H"""
    <div id={@id} class={@class} phx-hook="Combobox">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: ""

  attr(:rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
         multiple pattern placeholder readonly required rows size step)
  )

  def combobox_input(assigns) do
    ~H"""
    <input type="text" class={@class} tabindex="0" {@rest} />
    """
  end

  slot :inner_block, required: true
  attr :class, :string, default: ""
  attr :transition_enter, :any, default: nil
  attr :transition_leave, :any, default: nil

  def combobox_options(assigns) do
    ~H"""
    <div
      class={@class}
      style="display: none;"
      js-show={JS.show(transition: @transition_enter)}
      js-hide={JS.hide(transition: @transition_leave)}
      data-livekit-ref="options"
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  slot :inner_block, required: true
  attr :class, :string, default: ""
  attr :value, :any, required: true

  def combobox_option(assigns) do
    ~H"""
    <div role="option" class={@class} data-value={@value}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
