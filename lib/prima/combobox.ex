defmodule Prima.Combobox do
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
      data-prima-ref="search_input"
      type="text"
      autocomplete="off"
      class={@class}
      name={@name <> "_search"}
      tabindex="0"
      phx-debounce={200}
      {@rest}
    />
    <div phx-update="ignore" id={@name <> "_submit_container"}>
      <input data-prima-ref="submit_input" type="hidden" autocomplete="off" name={@name} />
    </div>
    """
  end

  slot :inner_block, required: true
  attr :class, :string, default: ""
  attr :id, :string, required: true
  attr :placement, :string, default: "bottom-start"
  attr :flip, :boolean, default: true
  attr :transition_enter, :any, default: nil
  attr :transition_leave, :any, default: nil
  attr(:rest, :global)

  def combobox_options(assigns) do
    ~H"""
    <.portal id={"#{@id}-portal"} target="body">
      <div
        id={@id}
        class={@class}
        style="display: none;"
        js-show={JS.show(transition: @transition_enter)}
        js-hide={JS.hide(transition: @transition_leave)}
        phx-click-away={JS.dispatch("prima:combobox:reset")}
        data-prima-ref="options"
        data-placement={@placement}
        data-flip={@flip}
        {@rest}
      >
        {render_slot(@inner_block)}
      </div>
    </.portal>
    """
  end

  slot :inner_block, required: true
  attr :class, :string, default: ""
  attr :value, :any, required: true
  attr(:rest, :global)

  def combobox_option(assigns) do
    ~H"""
    <div role="option" class={@class} data-value={@value} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: ""

  def creatable_option(assigns) do
    ~H"""
    <div
      role="option"
      data-prima-ref="create-option"
      data-value="__CREATE__"
      class={@class}
    >
    </div>
    """
  end
end
