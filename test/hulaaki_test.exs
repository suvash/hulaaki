defmodule HulaakiTest do
  use ExUnit.Case

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "this is another" do
    assert Hulaaki.what
  end

  test "add two numbers" do
    assert Hulaaki.add(1,23) == 24
  end
end
