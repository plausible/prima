defmodule PrimaWeb.ErrorJSON do
  @moduledoc false

  # If you want to customize error responses,
  # you can define the `render/2` function below. For example:
  #
  # def render(template, _assigns) do
  #   %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  # end
  #
  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end