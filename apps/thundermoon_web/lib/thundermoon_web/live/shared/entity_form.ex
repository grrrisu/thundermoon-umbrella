defmodule ThundermoonWeb.Component.EntityForm do
  defmacro __using__(opts) do
    # "vegetation"
    params_name = opts[:params_name]
    # LotkaVolterra.Vegetation -> %Vegetation{}
    model = opts[:model]
    # Thundermoon.LotkaVolterra.VegetationForm
    form_data = opts[:form_data]

    quote do
      use ThundermoonWeb, :live_component

      @params_name unquote(params_name)
      @model %unquote(model){}
      @form_data unquote(form_data)

      @impl true
      def update(assigns, socket) do
        {:ok,
         socket
         |> assign(assigns)
         |> clear_flash()
         |> assign(creating: not Map.has_key?(assigns, :data))
         |> assign(changeset: get_changeset(assigns))}
      end

      @impl true
      def handle_event("validate", %{@params_name => params}, socket) do
        changeset =
          @model
          |> @form_data.changeset(params)
          |> Map.put(:action, :insert)

        {:noreply, socket |> clear_flash |> assign(changeset: changeset)}
      end

      @impl true
      def handle_event("create", %{@params_name => params}, socket) do
        socket = clear_flash(socket)

        case apply_params(params) do
          {:ok, entity} ->
            {:noreply, entity_submitted(entity, socket)}

          {:error, changeset} ->
            {:noreply,
             validation_failed(socket, changeset, "parameters for #{@params_name} are not valid")}
        end
      end

      def get_changeset(%{data: data}) when not is_nil(data) do
        data |> @form_data.changeset()
      end

      def get_changeset(_assigns) do
        @model |> @form_data.changeset()
      end

      defp apply_params(params) do
        @form_data.changeset(@model, params)
        |> @form_data.apply_action(:update)
      end

      defp validation_failed(socket, changeset, message) do
        socket
        |> put_flash(:error, message)
        |> assign(changeset: changeset)
      end
    end
  end
end
