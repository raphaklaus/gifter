defmodule TimeDuration do
  def convert(time_duration) do
    time_duration
    |> String.graphemes()
    |> Enum.map(&convert_integers/1)
    |> Enum.reduce(%{total: 0, sub_total: ""}, fn character, acc ->
      case character do
        time_unit when is_bitstring(time_unit) -> calculate(time_unit, acc)
        number -> %{acc | sub_total: acc.sub_total <> Integer.to_string(number)}
      end
    end)
    |> (&case Map.has_key?(&1, :error) do
      true -> :invalid_time_duration
      _ -> {:ok, &1.total}
    end).()
  end

  defp convert_integers(element) do
    case Integer.parse(element) do
      {number, _} -> number
      :error -> element
    end
  end

  defp calculate(time_unit, acc) do
    case time_unit do
      "H" ->
        hours = String.to_integer(acc.sub_total)
        %{acc | sub_total: "", total: acc.total + hours * 60 * 60}
      "M" ->
        minutes = String.to_integer(acc.sub_total)
        %{acc | sub_total: "", total: acc.total + minutes * 60}
      "S" ->
        seconds = String.to_integer(acc.sub_total)
        %{acc | sub_total: "", total: acc.total + seconds}
      _ ->
        Map.put(acc, :error, :invalid_time_duration)
    end
  end
end
