defmodule ThundermoonWeb.ChatMessages do
  use GenServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add(message) do
    GenServer.call(__MODULE__, {:add, message})
  end

  def list do
    GenServer.call(__MODULE__, :list)
  end

  def clear do
    GenServer.call(__MODULE__, :clear)
  end

  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:add, new_message}, _from, messages) do
    new_messages = [new_message | messages]
    {:reply, new_messages, new_messages}
  end

  def handle_call(:list, _from, messages) do
    {:reply, messages, messages}
  end

  def handle_call(:clear, _from, _messages) do
    {:reply, [], []}
  end
end
