defmodule Gifter do
  alias Gifter.TimeDuration
  def http_adapter, do: Application.get_env(:gifter, :http_adapter)

  def convert(url, start_time, end_time) do
    with :ok <- check_youtube(url),
      :ok <- check_time(start_time, end_time),
      :ok <- correct_duration(url, start_time, end_time) do
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
    with duration_string when is_bitstring(duration_string) <- get_video_duration(url),
      {:ok, duration} <- Gifter.TimeDuration.convert(duration_string),
      :ok <- is_inside_interval(duration, start_time, end_time) do
      :ok
    else
      error ->
        error
    end
  end

  defp is_inside_interval(duration, start_time, end_time) do
    case start_time in 0..duration and end_time in 0..duration do
      true -> :ok
      _ -> :time_error
    end
  end

  defp get_video_duration(url) do
    case http_adapter().get(url, %{}, []) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, result} = Poison.Parser.parse(body, %{keys: :atoms})
        [first | _] = result.items
        first.contentDetails.duration
      _ ->
        :error
    end
  end

  defp check_youtube(url) do
    case Regex.match?(~r/(http(s)?:\/\/)?(www.)?youtube\.com/, url) do
      false -> :invalid_source
      _ -> :ok
    end
  end
end
