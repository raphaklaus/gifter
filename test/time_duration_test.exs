defmodule TimeDurationTest do
  alias Gifter.TimeDuration
  use ExUnit.Case

  describe "convert duration to seconds" do
    test "it should convert PT2S to 2 seconds" do
      assert {:ok, 2} = TimeDuration.convert("PT2S")
    end

    test "it should convert PT1H to 3600 seconds" do
      assert {:ok, 3600} = TimeDuration.convert("PT1H")
    end

    test "it should convert PT30M59S to 1859 seconds" do
      assert {:ok, 1859} = TimeDuration.convert("PT30M59S")
    end

    test "it should convert PT2H51M9S to 10269 seconds" do
      assert {:ok, 10269} = TimeDuration.convert("PT2H51M9S")
    end

    test "it should not convert if format is PT23Y2M4D7H20M2S" do
      assert :invalid_time_duration == TimeDuration.convert("PT23Y2M4D7H20M2S")
    end

    test "it should not convert if format is PT3D21H17M10S" do
      assert :invalid_time_duration == TimeDuration.convert("PT3D21H17M10S")
    end
  end
end
