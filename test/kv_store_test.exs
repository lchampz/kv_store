defmodule KvStoreTest do
  use ExUnit.Case
  doctest KvStore

  test "greets the world" do
    assert KvStore.hello() == :world
  end
end
