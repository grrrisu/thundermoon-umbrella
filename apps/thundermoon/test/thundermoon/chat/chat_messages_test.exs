defmodule Thundermoon.ChatMessagesTest do
  use ExUnit.Case, async: true

  alias Thundermoon.ChatMessages

  setup(_) do
    ChatMessages.clear()
  end

  test "add message" do
    ChatMessages.add(%{user: "crumb", text: "fritz the cat", user_id: 5})
    assert ChatMessages.list() == [%{user: "crumb", text: "fritz the cat", user_id: 5}]
  end

  test "clear all messages" do
    ChatMessages.add(%{user: "crumb", text: "fritz the cat", user_id: 5})
    ChatMessages.clear()
    assert ChatMessages.list() == []
  end
end
