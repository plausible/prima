defmodule Livekit.Combobox do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  slot :inner_block, required: true
  attr :class, :string, default: ""

  def combobox(assigns) do
    ~H"""
    <div id={@id} class={@class} phx-hook="Combobox">
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""
  attr :name, :string, required: true
  attr(:rest, :global, include: ~w(placeholder phx-change phx-target))

  def combobox_input(assigns) do
    ~H"""
    <input
      data-livekit-ref="search_input"
      type="text"
      autocomplete="off"
      class={@class}
      name={@name <> "_search"}
      tabindex="0"
      phx-debounce={200}
      {@rest}
    />
    <div phx-update="ignore" id={@name <> "_submit_container"}>
      <input data-livekit-ref="submit_input" type="hidden" autocomplete="off" name={@name} />
    </div>
    """
  end

  slot :inner_block, required: true
  attr :class, :string, default: ""
  attr :id, :string, default: ""
  attr :transition_enter, :any, default: nil
  attr :transition_leave, :any, default: nil
  attr(:rest, :global)

  def combobox_options(assigns) do
    ~H"""
    <div
      id={@id}
      class={@class}
      style="display: none;"
      js-show={JS.show(transition: @transition_enter)}
      js-hide={JS.hide(transition: @transition_leave)}
      phx-click-away={JS.dispatch("livekit:combobox:reset")}
      data-livekit-ref="options"
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :inner_block, required: true
  attr :id, :string, default: nil
  attr :class, :string, default: ""
  attr :value, :any, required: true

  def combobox_option(assigns) do
    assigns = assign(assigns, id: assigns.id || assigns.value)

    ~H"""
    <div role="option" id={@id} class={@class} data-value={@value}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
