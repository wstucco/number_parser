defmodule ParseItNumTest do
  use ExUnitProperties
  use ExUnit.Case
  doctest NumberParser

  property "an integer is alwaysed parsed as integer" do
    check all num <- integer() do
      assert NumberParser.parse("#{num}") == {:ok, num}
    end
  end

  property "a number containing a single comma is converted to float" do
    check all num <- float(), initial_seed: 192_778 do
      num_string = to_string(num) |> String.replace(".", ",")
      assert NumberParser.parse(num_string) == {:ok, num}
    end
  end

  property "thousands separator appear before triplets" do
    check all sign <- signs(),
              left <- string(?1..?9, min_length: 1, max_length: 3),
              right <- string(?0..?9, length: 3) do
      assert NumberParser.parse("#{sign}#{left}.#{right}") ==
               {:ok, String.to_integer("#{sign}#{left}#{right}")}
    end
  end

  property "thousands separator can appear only before triplets" do
    check all sign <- signs(),
              left <- string(?1..?9, min_length: 1),
              right <- string(?0..?9, min_length: 1) do
      case {String.length(left) <= 3, String.length(right) == 3} do
        {true, true} ->
          assert NumberParser.parse("#{sign}#{left}.#{right}") ==
                   {:ok, String.to_integer("#{sign}#{left}#{right}")}

        _ ->
          {:error, reason} = NumberParser.parse("#{sign}#{left}.#{right}")
          assert reason == "invalid number format #{sign}#{left}.#{right}"
      end
    end
  end

  property "a number can contain thousands separators and decimals" do
    check all sign <- signs(),
              left <- string(?1..?9, min_length: 1, max_length: 3),
              right <- string(?0..?9, length: 3),
              decimal <- string(?0..?9, min_length: 1) do
      num = String.to_float("#{sign}#{left}#{right}.#{decimal}")
      assert NumberParser.parse("#{sign}#{left}.#{right},#{decimal}") == {:ok, num}
    end
  end

  property "scientific notation accepts positive and negative exponents" do
    check all sign <- signs(),
              left <- positive_integer(),
              right <- string(?0..?9, min_length: 1) do
      num = String.to_float("#{left}.#{right}e#{sign}2")
      assert NumberParser.parse("#{left},#{right}e#{sign}2") == {:ok, num}
    end
  end

  defp signs do
    one_of([constant("-"), constant("+")])
  end
end
