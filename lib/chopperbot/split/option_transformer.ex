defmodule Chopperbot.Split.OptionTransformer do
  @percentage_pattern ~r/^(\+|-)(\d+|\d+[.]\d+)(%)$/

  @doc """
  Transform options to a multiplier.

  ## Examples
      iex> transform(["+vat"])
      {:ok, 1.07}

      iex> transform(["+s", "+v"])
      {:ok, 1.177}

      iex> transform(["-20%"])
      {:ok, 0.8}

      iex> transform(["+service", "+vat", "-25%"])
      {:ok, 0.88275}

      iex> transform([])
      {:ok, 1.0}

      iex> transform(["+v", "-10!", "-invalid", "-5%", "-ten%"])
      {:error, :invalid_option, ["-10!", "-invalid", "-ten%"]}
  """
  @spec transform([String.t()]) :: {:ok, float()} | {:error, :invalid_option, [String.t()]}
  def transform(options) do
    case transform_to_multipliers(options) do
      {multipliers, []} ->
        {:ok, accumulate_multipliers(multipliers)}

      {_, invalid_options} ->
        {:error, :invalid_option, invalid_options}
    end
  end

  defp transform_to_multipliers(options, multipliers \\ [], invalid_options \\ [])

  defp transform_to_multipliers([option | rest_options], multipliers, invalid_options) do
    case get_multiplier_from_option(option) do
      {:ok, multiplier} ->
        transform_to_multipliers(rest_options, [multiplier | multipliers], invalid_options)

      :error ->
        transform_to_multipliers(rest_options, multipliers, [option | invalid_options])
    end
  end

  defp transform_to_multipliers([], multipliers, invalid_options) do
    {multipliers, Enum.reverse(invalid_options)}
  end

  defp get_multiplier_from_option(option) when option in ["+service", "+s"] do
    get_multiplier_from_option("+10%")
  end

  defp get_multiplier_from_option(option) when option in ["+vat", "+v"] do
    get_multiplier_from_option("+7%")
  end

  defp get_multiplier_from_option(option) do
    case Regex.run(@percentage_pattern, option) do
      [^option, operator, number, "%"] ->
        {float_number, ""} = Float.parse(number)

        multiplier =
          Kernel
          |> apply(String.to_existing_atom(operator), [100, float_number])
          |> Kernel./(100)

        {:ok, multiplier}

      _ ->
        :error
    end
  end

  defp accumulate_multipliers(multipliers) do
    multipliers
    |> Enum.reduce(1.0, &(&1 * &2))
    |> Float.round(15)
  end
end
