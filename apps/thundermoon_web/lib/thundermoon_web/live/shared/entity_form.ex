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
         |> assign(changeset: empty_form())}
      end

      @impl true
      def handle_event("validate", %{@params_name => params}, socket) do
        changeset =
          @model
          |> @form_data.changeset(params)
          |> Map.put(:action, :insert)

        {:noreply, assign(socket, changeset: changeset)}
      end

      @impl true
      def handle_event("create", %{@params_name => params}, socket) do
        case apply_params(params) do
          {:ok, entity} ->
            send(self(), {:entity_submitted, entity})
            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, validation_failed(socket, changeset, "creating #{@params_name} failed")}
        end
      end

      def empty_form() do
        @model
        |> @form_data.changeset()
      end

      defp apply_params(params) do
        @form_data.changeset(@model, params)
        |> @form_data.apply_valid_changes()
      end

      defp validation_failed(socket, changeset, message) do
        socket
        |> put_flash(:error, message)
        |> assign(changeset: changeset)
      end
    end
  end
end
