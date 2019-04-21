defmodule GifterTest do
  use ExUnit.Case
  import Mox
  doctest Gifter

  setup :verify_on_exit!

  # @gif_binary "tbd"

  @youtube_video_details_response ~s({
    "kind": "youtube#videoListResponse",
    "etag": "\\\"XpPGqXPfxQJhLgs6en2_n8JR4Qk/ZSocz3fb91hlCSp196j-4z9s22F\\\"",
    "pageInfo": {
    "totalResults": 1,
    "resultsPerPage": 1
    },
    "items": [{
      "kind": "youtube#video",
      "etag": "\\\"XpPGqXPfxQJhLgs6en2_n8JR4Qk/ZSocz3fb91hlCSp196j-4z9s22F\\\"",
      "id": "1",
      "contentDetails": {
        "duration": "PT1M2S",
        "dimension": "2d",
        "definition": "sd",
        "caption": "false",
        "licensedContent": false,
        "projection": "rectangular"
      }
    }]
  })

  setup do
    Gifter.HTTPMock
    |> stub(:get, fn _url, _body, _headers ->
      {:ok, %HTTPoison.Response{status_code: 200, body: @youtube_video_details_response}}
    end)

    :ok
  end

  describe "basic validations" do
    test "it should return an error for non-youtube video sources" do
      assert :invalid_source = Gifter.convert("https://vimeo.com/Wjf32sd", 0, 3)
    end

    test "it should be okay if the source is from YouTube" do
      assert {:enqueued, _} = Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 0, 3)
    end

    test "it should return an error if more than 5 seconds" do
      assert :interval_forbidden == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 0, 15)
    end

    test "it should be okay if less or equal to 5 seconds" do
      assert {:enqueued, _} = Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 0, 3)
      assert {:enqueued, _} = Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 0, 5)
    end

    test "it should return error if start and end are equal" do
      assert :no_time_difference == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 1, 1)
      assert :no_time_difference == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 2, 2)
      assert :no_time_difference == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 15, 15)
    end

    test "it should return error if start is greater than end" do
      assert :negative_difference == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 4, 2)
      assert :negative_difference == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 9, 8)
    end

    test "it should return error if start or end are not positive numbers" do
      assert :time_error == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", -1, 4)
      assert :time_error == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 4, -6)
      assert :time_error == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", "2", 2)
      assert :time_error == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", "2", "2")
      assert :time_error == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 1, "2")
      assert :time_error == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", -15, -15)
      assert :time_error == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", -15, -16)
    end

    test "it should return error if start or end is greater than clip's duration" do
      assert :time_error == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 300, 302)
      assert :time_error == Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 300, 304)
    end
  end

  describe "external problems" do
    @tag :skip
    test "it should present an error if YouTube API's quota is over" do
      assert :quota_over ==  Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 0, 4)
    end

    @tag :skip
    test "it should present an error if YouTube API's is not responding" do
      assert :youtube_timeout ==  Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 0, 4)
    end
  end

  describe "video to gif" do
    @tag :skip
    test "it should enqueue correctly the request, process it and send an email" do
      assert {:enqueued, id} = Gifter.convert("https://www.youtube.com/watch?v=1qaMTmNOVW4", 0, 5)

      sent_event = :"sent_to_consumer_#{id}"
      done_event = :"done_#{id}"
      email_sent_event = :"email_sent_#{id}"

      assert_received sent_event
      assert_received {done_event, <<71, 73, 70, data :: binary>>}
      assert_received email_sent_event
    end
  end
end
