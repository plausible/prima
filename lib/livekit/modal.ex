defmodule Livekit.Modal do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :class, :string, default: ""

  slot :inner_block

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      js-show={JS.show()}
      js-hide={JS.hide()}
      style="display: none;"
      phx-hook="Modal"
      class={@class}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: ""
  attr :transition_enter, :any, default: nil
  attr :transition_leave, :any, default: nil

  def modal_overlay(assigns) do
    ~H"""
    <div
      style="display: none;"
      js-show={JS.show(transition: @transition_enter)}
      js-hide={JS.hide(transition: @transition_leave)}
      livekit-ref="modal-overlay"
      class={@class}
    >
    </div>
    """
  end

  attr :class, :string, default: ""
  attr :transition_enter, :any, default: nil
  attr :transition_leave, :any, default: nil
  slot :inner_block

  def modal_panel(assigns) do
    ~H"""
    <.focus_wrap
      id="id-for-focus-wrap"
      style="display: none;"
      js-show={JS.show(transition: @transition_enter)}
      js-hide={JS.hide(transition: @transition_leave)}
      livekit-ref="modal-panel"
      phx-window-keydown={close()}
      phx-key="escape"
      phx-click-away={close()}
      class={@class}
    >
      <%= render_slot(@inner_block) %>
    </.focus_wrap>
    """
  end

  def open(id) do
    JS.dispatch("livekit:modal:open", to: "##{id}")
  end

  def close() do
    JS.dispatch("livekit:modal:close")
  end
end
