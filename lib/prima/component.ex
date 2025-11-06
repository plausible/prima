defmodule Prima.Component do
  @moduledoc false
  import Phoenix.Component, only: [dynamic_tag: 1]

  @doc """
  Renders a component using either a custom component function, a custom tag name, or a default HTML tag.

  This helper function provides a consistent pattern for components that support
  the `as` attribute for custom rendering.

  ## Parameters

    * `assigns` - The component assigns map
    * `default_tag` - The default HTML tag name (string) to use when no custom
      component is specified

  ## Returns

  Returns the rendered component by either:
    * Calling the custom component function with merged assigns (if `as` is a function)
    * Rendering a dynamic tag with the custom tag name (if `as` is a string)
    * Rendering a dynamic tag with the default tag name (if `as` is not provided)

  ## Behavior

  1. Pops the `:as` attribute from assigns
  2. Pops and merges the `:rest` attributes into assigns
  3. If `as` is a function, calls it with the merged assigns
  4. If `as` is a string, renders a dynamic tag with that tag name
  5. Otherwise, renders a dynamic tag with default tag name

  ## Examples

      # With default tag name
      def my_component(assigns) do
        assigns = assign(assigns, %{"aria-label": "My Component"})
        render_as(assigns, "button")
      end

      # Can be used with as={&custom_component/1}
      <.my_component as={&custom_component/1} />

      # Can be used with as="span"
      <.my_component as="span" />

  """
  def render_as(assigns, default_tag) when is_binary(default_tag) do
    {as, assigns} = Map.pop(assigns, :as)
    {rest, assigns} = Map.pop(assigns, :rest, %{})
    assigns = Map.merge(assigns, rest)

    cond do
      is_nil(as) ->
        dynamic_tag(Map.merge(assigns, %{tag_name: default_tag}))

      is_function(as) ->
        as.(assigns)

      is_binary(as) ->
        dynamic_tag(Map.merge(assigns, %{tag_name: as}))

      true ->
        raise "Cannot render component `as` #{inspect(as)}. Expected a function or string"
    end
  end
end
