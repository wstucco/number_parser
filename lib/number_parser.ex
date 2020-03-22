defmodule NumberParser do
  import NimbleParsec

  @moduledoc """
  In most European countries decimal separator is the , (comma)
  This is a simple parser for numbers formatted that way
  """

  int = integer(min: 1)
  decimal_sep = string(",")
  thousands_sep = string(".")
  plus_sing = string("+")
  minus_sign = string("-")
  sign = choice([plus_sing, minus_sign])
  num_range = [?0..?9]
  num_string = ascii_string(num_range, min: 1)

  sign_part = optional(sign)
  integer_part = concat(sign_part, int)
  e_part = optional(string("e") |> concat(integer_part))
  decimal_part = decimal_sep |> concat(num_string) |> concat(e_part)

  thousands_start = concat(sign_part, integer(min: 1, max: 3))
  thousand_triplet = ascii_string(num_range, 3)
  thousands_triplets = times(ignore(thousands_sep) |> concat(thousand_triplet), min: 1)
  thousands_part = thousands_start |> concat(thousands_triplets)

  defcombinatorp(
    :number,
    choice([
      thousands_part |> concat(decimal_part),
      integer_part |> concat(decimal_part),
      thousands_part,
      integer_part
    ])
    |> eos()
    |> post_traverse(:to_number_value)
  )

  @doc """
  Parse numbers in Italian format
  Returns
  {:ok, number} in case of success or
  {:error, reason, rest} if the parser can't make sense of it
  ## Examples
    iex> NumberParser.parse("89")
    {:ok, 89}
    iex> NumberParser.parse("89,91")
    {:ok, 89.91}
    iex> NumberParser.parse("89.000")
    {:ok, 89000}
    iex> NumberParser.parse("89.000,12")
    {:ok, 89000.12}
    iex> NumberParser.parse("89.000,12e1")
    {:ok, 890001.2}
    iex> NumberParser.parse("-89.000,12e1")
    {:ok, -890001.2}
    iex> NumberParser.parse("+89.000,12e1")
    {:ok, 890001.2}
    iex> NumberParser.parse("-89.000,12e-1")
    {:ok, -8900.012}
    iex> NumberParser.parse("89.91")
    {:error, "invalid number format 89.91"}
  """
  def parse(term) when is_binary(term) do
    case parse_number(term) do
      {:error, _, _, _, _, _} -> {:error, "invalid number format #{term}"}
      {:ok, [val], _, _, _, _} -> {:ok, val}
    end
  end

  defparsecp(:parse_number, parsec(:number))

  # parse plain numbers like 89
  defp to_number_value(_, [num], context, _, _) when is_integer(num) do
    {[num], context}
  end

  # parse floats with decimals like 12.000,2 or 11,25
  defp to_number_value(_, [decimal_part, "," | tail], context, _, _) do
    integer_part = tail |> Enum.reverse() |> Enum.join("")
    {[String.to_float("#{integer_part}.#{decimal_part}")], context}
  end

  # parse floats with exponential notation like 1,25-e3
  defp to_number_value(_, [exp, "e", decimal_part, "," | tail], context, _, _) do
    num = from_exponential_notation(tail, decimal_part, exp, "+")
    {[num], context}
  end

  # parse floats with negative exponential notation like 1,25e-3
  defp to_number_value(_, [exp, sign, "e", decimal_part, "," | tail], context, _, _) do
    num = from_exponential_notation(tail, decimal_part, exp, sign)
    {[num], context}
  end

  # parse ints with thousands separator like 2.450
  defp to_number_value(_, args, context, _, _) do
    integer_part = args |> Enum.reverse() |> Enum.join("")
    {[String.to_integer(integer_part)], context}
  end

  defp from_exponential_notation(integer_parts, decimal_part, exp, sign) do
    integer_part = integer_parts |> Enum.reverse() |> Enum.join("")
    String.to_float("#{integer_part}.#{decimal_part}e#{sign}#{exp}")
  end
end
