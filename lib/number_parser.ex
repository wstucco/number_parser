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
  e_part = string("e") |> concat(int)
  decimal_part = decimal_sep |> concat(num_string) |> concat(optional(e_part))

  thousands_start = concat(sign_part, integer(min: 1, max: 3))
  thousands_triplets = repeat(ignore(thousands_sep) |> concat(ascii_string(num_range, 3)))
  thousands_part = thousands_start |> concat(thousands_triplets)

  defcombinatorp(
    :number,
    choice([
      integer_part |> concat(decimal_part),
      thousands_part |> concat(decimal_part),
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
    iex> NumberParser.parse("89.91")
    {:error, "expected end of string", ".91"}
  """
  def parse(term) when is_binary(term) do
    case parse_number(term) do
      {:error, reason, rest, _, _, _} -> {:error, reason, rest}
      {:ok, [val], _, _, _, _} -> {:ok, val}
    end
  end

  defparsecp(:parse_number, parsec(:number))

  # parse plain numbers like 89
  defp to_number_value(_, [num], context, _, _) when is_integer(num) do
    {[num], context}
  end

  # parse floats like 11,25
  defp to_number_value(_, [right, ",", left], context, _, _)
       when is_integer(left) and is_binary(right) do
    {[String.to_float("#{left}.#{right}")], context}
  end

  # parse floats like 1,25e3
  defp to_number_value(_, [exp, "e", right, ",", left], context, _, _)
       when is_integer(left) and is_binary(right) and is_integer(exp) do
    {[String.to_float("#{left}.#{right}e#{exp}")], context}
  end

  # parse floats with thousands separator and decimals like 12.000,2
  defp to_number_value(_, [decimal_part, "," | tail], context, _, _) do
    int_part = tail |> Enum.reverse() |> Enum.join("")
    {[String.to_float("#{int_part}.#{decimal_part}")], context}
  end

  # parse floats with thousands separator and decimals like 1.152,921504606847e15
  defp to_number_value(_, [exp, "e", decimal_part, "," | tail], context, _, _) do
    int_part = tail |> Enum.reverse() |> Enum.join("")
    {[String.to_float("#{int_part}.#{decimal_part}e#{exp}")], context}
  end

  # parse ints with thousands separator like 2.450
  defp to_number_value(_, args, context, _, _) do
    int_part = args |> Enum.reverse() |> Enum.join("")
    {[String.to_integer(int_part)], context}
  end
end
