defmodule TimeDurationTest do
  use ExUnit.Case

  describe "convert duration to seconds" do
    test "it should convert 2S to 2 seconds" do
      assert {:ok, 2} = TimeDuration.convert("2S")
    end

    test "it should convert 1H to 3600 seconds" do
      assert {:ok, 3600} = TimeDuration.convert("1H")
    end

    test "it should convert 30M59S to 1859 seconds" do
      assert {:ok, 1859} = TimeDuration.convert("30M59S")
    end

    test "it should convert 2H51M9S to 10269 seconds" do
      assert {:ok, 10269} = TimeDuration.convert("2H51M9S")
    end

    test "it should not convert if format is 2P3Y2M4D7H20M2S" do
      assert :invalid_time_duration == TimeDuration.convert("2P3Y2M4D7H20M2S")
    end

    test "it should not convert if format is 3D21H17M10S" do
      assert :invalid_time_duration == TimeDuration.convert("3D21H17M10S")
    end
  end
end
