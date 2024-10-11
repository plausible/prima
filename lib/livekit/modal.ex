defmodule Livekit.Modal do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :class, :string, default: ""
  attr :on_close, JS, default: %JS{}
  attr :show, :boolean, default: false

  slot :inner_block

  # TODO: phx-mounted does not work - the hook is not registered yet when the livekit:modal:open event is triggered
  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      js-show={JS.show()}
      js-hide={@on_close |> JS.hide()}
      phx-mounted={@show && open(@id)}
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

  slot :inner_block

  def modal_loader(assigns) do
    ~H"""
    <div
      livekit-ref="modal-loader"
      js-show={JS.show()}
      js-hide={JS.hide()}
      >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :class, :string, default: ""
  attr :transition_enter, :any, default: nil
  attr :transition_leave, :any, default: nil
  slot :inner_block

  def modal_panel(assigns) do
    ~H"""
    <.focus_wrap
      id={@id}
      style="display: none;"
      js-show={JS.show(transition: @transition_enter)}
      js-hide={JS.hide(transition: @transition_leave)}
      phx-mounted={panel_mounted()}
      phx-remove={panel_removed()}
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

  def panel_removed() do
    JS.dispatch("livekit:modal:panel-removed")
  end

  def panel_mounted() do
    JS.dispatch("livekit:modal:panel-mounted")
  end

  def open(id) do
    JS.dispatch("livekit:modal:open", to: "##{id}")
  end

  def close() do
    JS.dispatch("livekit:modal:close")
  end
end
