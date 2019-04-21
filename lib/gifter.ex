defmodule Gifter do
  @moduledoc """
  Documentation for Gifter.
  """

  def convert(url, start_time, end_time) do
    with :ok <- check_youtube(url),
      :ok <- check_time(start_time, end_time) do
      {:enqueued, 1}
    else
      error -> error
    end
  end

  defp check_time(start_time, end_time) when not is_number(start_time) or start_time < 0 or
    not is_number(end_time) or end_time < 0 do
    :time_error
  end

  defp check_time(start_time, end_time) when start_time > end_time do
    :negative_difference
  end

  defp check_time(start_time, end_time) when start_time == end_time do
    :no_time_difference
  end

  defp check_time(start_time, end_time) do
    case end_time - start_time in 0..5 do
      false -> :interval_forbidden
      _ -> :ok
    end
  end

  defp correct_duration(url, start_time, end_time) do
    case HTTPoison.get(url, %{}, [{}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        result = Poison.decode!(body)
        [first | _] = result.items
        first.contentDetails.duration
    end
  end

  defp check_youtube(url) do
    case Regex.match?(~r/(http(s)?:\/\/)?(www.)?youtube\.com/, url) do
      false -> :invalid_source
      _ -> :ok
    end
  end
end
