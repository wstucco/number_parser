defmodule ParseItNumTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest NumberParser

  property "an integer is alwaysed parsed as integer" do
    check all num <- positive_integer() do
      assert NumberParser.parse("#{num}") == {:ok, num}
    end
  end

  property "a number containing a single comma is converted to float" do
    check all num <- float(min: 1) do
      num_string = to_string(num) |> String.replace(".", ",")
      assert NumberParser.parse(num_string) == {:ok, num}
    end
  end
end
