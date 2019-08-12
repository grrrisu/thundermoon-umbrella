defmodule ThundermoonWeb.ChatMessagesTest do
  use ExUnit.Case, async: true

  alias ThundermoonWeb.ChatMessages

  setup(_) do
    ChatMessages.clear()
  end

  test "add message" do
    ChatMessages.add(%{user: "crumb", text: "fritz the cat"})
    assert ChatMessages.list() == [%{user: "crumb", text: "fritz the cat"}]
  end

  test "clear all messages" do
    ChatMessages.add(%{user: "crumb", text: "fritz the cat"})
    ChatMessages.clear()
    assert ChatMessages.list() == []
  end
end
