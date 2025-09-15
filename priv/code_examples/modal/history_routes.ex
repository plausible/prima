# In your router.ex
live "/demo", DemoLive, :index
live "/demo/modal-history", DemoLive, :modal_history

# In your LiveView module
def handle_params(_params, _url, socket) do
  case socket.assigns.live_action do
    :modal_history ->
      {:noreply, assign(socket, show_history_modal: true)}

    _ ->
      {:noreply, assign(socket, show_history_modal: false)}
  end
end
