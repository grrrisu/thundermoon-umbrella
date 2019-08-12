defmodule ThundermoonWeb.ChatMessagesTest do
  use ExUnit.Case, async: true

  alias ThundermoonWeb.ChatMessages

  setup do
    chat_messages = Process.whereis(ChatMessages)
    %{chat_messages: chat_messages}
  end

  test "start with an empty list", %{chat_messages: _chat_messages} do
    assert ChatMessages.list() == []
  end

  test "add message", %{chat_messages: _chat_messages} do
    ChatMessages.add(%{user: "crumb", text: "fritz the cat"})
    assert ChatMessages.list() == [%{user: "crumb", text: "fritz the cat"}]
  end

  test "clear all messages", %{chat_messages: _chat_messages} do
    ChatMessages.add(%{user: "crumb", text: "fritz the cat"})
    ChatMessages.clear()
    assert ChatMessages.list() == []
  end
end
