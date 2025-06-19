<button
  phx-click={Livekit.Modal.open("async-modal") |> JS.push("open-modal")}
>
  Open Modal
</button>

<Livekit.Modal.modal on_close={JS.push("close-modal")} id="async-modal">
  <Livekit.Modal.modal_overlay class="fixed inset-0 bg-black/50" />
  <Livekit.Modal.modal_loader>... spinner ...</Livekit.Modal.modal_loader>

  <div class="fixed inset-0 flex items-center justify-center p-4">
    <Livekit.Modal.modal_panel :if={@modal_open?} id="modal-panel" class="bg-white rounded p-6">
      <p>Hello Modal!</p>
      <button phx-click={Livekit.Modal.close()}>Close</button>
    </Livekit.Modal.modal_panel>
  </div>
</Livekit.Modal.modal>
