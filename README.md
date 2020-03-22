# NumberParser

Parse numbers in Italian format and returns the equivalent native value.

Italian locale uses `,` as decimal separator and `.` as thousands separator and numbers look like this *1.234.567,89*.

The implementation also recognize numbers written in scientific notation 
with positive and negative exponents like *1.234,12e-1* or *1.234,12e2* or *1.234,12e+2*.


The same style is used in the following countries: Argentina, Austria, Belgium (Dutch), 
Bosnia and Herzegovina, Brazil, Chile, Colombia, Costa Rica, Croatia, Denmark, 
Germany, Greece, Indonesia, Italy, Netherlands, Romania, Slovenia, Spain, Turkey and Vietnam. 


I wrote this parser mainly as an excercise to learn how to use the [Nimble Parsec](https://github.com/dashbitco/nimble_parsec) library.




## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `parse_it_num` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:number_parser, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/parse_it_num](https://hexdocs.pm/parse_it_num).

