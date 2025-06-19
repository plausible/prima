# Handle modal open/close events in your LiveView
def handle_event("open_form_modal", _params, socket) do
  {:noreply, assign(socket, form_modal_open?: true)}
end

def handle_event("close_form_modal", _params, socket) do
  {:noreply, assign(socket, form_modal_open?: false)}
end