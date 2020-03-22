defmodule ParseItNumTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest NumberParser

  property "an integer is alwaysed parsed as integer" do
    check all num <- integer() do
      IO.inspect(num)
      assert NumberParser.parse("#{num}") == {:ok, num}
    end
  end

  property "a number containing a single comma is converted to float" do
    check all num <- float(min: 1) do
      num_string = to_string(num) |> String.replace(".", ",")
      assert NumberParser.parse(num_string) == {:ok, num}
    end
  end

  property "thousands separator appear before triplets" do
    check all left <- string(?1..?9, min_length: 1, max_length: 3),
              right <- string(?0..?9, length: 3) do
      assert NumberParser.parse("#{left}.#{right}") == {:ok, String.to_integer(left <> right)}
    end
  end

  property "thousands separator can appear only before triplets" do
    check all left <- string(?1..?9, min_length: 1),
              right <- string(?0..?9, min_length: 1) do
      case {String.length(left) <= 3, String.length(right) == 3} do
        {true, true} ->
          assert NumberParser.parse("#{left}.#{right}") == {:ok, String.to_integer(left <> right)}

        _ ->
          assert {:error, "expected end of string", _} = NumberParser.parse("#{left}.#{right}")
      end
    end
  end

  property "a number can contain thousands separators and decimals" do
    check all left <- string(?1..?9, min_length: 1, max_length: 3),
              right <- string(?0..?9, length: 3),
              decimal <- string(?0..?9, min_length: 1) do
      num = String.to_float("#{left}#{right}.#{decimal}")
      assert NumberParser.parse("#{left}.#{right},#{decimal}") == {:ok, num}
    end
  end
end
