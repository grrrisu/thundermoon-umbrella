defmodule ThundermoonWeb.LotkaVolterraLive.New do
  use ThundermoonWeb, :live_view

  alias Thundermoon.LotkaVolterra.FormData
  alias LotkaVolterra.{Vegetation, Herbivore}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(changeset: set_changeset())}
  end

  @impl true
  def handle_event("validate", %{"vegetation" => params}, socket) do
    changeset =
      %Vegetation{}
      |> FormData.changeset(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("create", %{"vegetation" => params}, socket) do
    case FormData.apply_params(%Vegetation{}, params) do
      {:ok, vegetation} ->
        sim_id = create_sim(vegetation)

        {:noreply,
         socket
         |> put_flash(:info, "successfully created vegetation")
         |> push_redirect(to: Routes.lotka_volterra_index_path(socket, :index, sim_id: sim_id))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "creating vegetation failed")
         |> assign(changeset: changeset)}
    end
  end

  defp create_sim(vegetation) do
    {sim_id, _object} = LotkaVolterra.create({vegetation, %Herbivore{}}, ThundermoonWeb.PubSub)
    sim_id
  end

  defp set_changeset() do
    FormData.changeset(%Vegetation{})
  end
end
