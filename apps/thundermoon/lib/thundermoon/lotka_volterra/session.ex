defmodule Thundermoon.Session do
  @enforce_keys [:subject_pid, :subject_ref]
  defstruct [:subject_pid, :subject_ref, :listener_pid, :listener_ref, running: false]
end
