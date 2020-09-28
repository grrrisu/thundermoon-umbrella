defmodule ThundermoonWeb.GameOfLifeLive.FormComponent do
  use ThundermoonWeb, :live_component

  alias GameOfLife.FormData
  alias ThundermoonWeb.GameOfLifeLive.Index

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, changeset: empty_changeset())}
  end

  @impl true
  def handle_event("validate", %{"form_data" => params}, socket) do
    changeset =
      socket.assigns.changeset.data
      |> FormData.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("create", %{"form_data" => params}, socket) do
    changeset = FormData.changeset(socket.assigns.changeset, params)

    case FormData.apply_valid_changes(changeset) do
      {:ok, data} ->
        send(self(), {:form_submitted, data.size})

      {:error, changeset} ->
        IO.inspect(changeset)
        assign(socket, changeset: changeset)
    end

    {:noreply, socket}
  end

  defp empty_changeset() do
    FormData.changeset(%FormData{})
  end
end
