defmodule NissCore.CeilingStrip.ParseSignalTest do
  use NissCore.TestCase
  alias NissCore.CeilingStrip.ParseSignal, as: Subject
  alias NissCore.IRSignalSupport

  @sample_signal """
                 1491871547,09075091,14504582,0623805,1508711,0596249,1539304,0600213,1537155,059
                 7361,1539840,0616861,1521174,0596249,1541767,0595194,1538637,0598286,1539063,059
                 8083,11652486,0602490,11672024,0570508,11690801,0569601,11642597,0600823,1164843
                 1,0600360,11655339,0588212,11652893,0599490,11650172,0593878,1538360,0630138,150
                 6211,0599860,11653005,0600453,11648912,0624417,1508340,0597786,1537915,0630917,1
                 505636,0600212,1535841,0603824,11645023,0627472,11622856,0598953,1534174,0628194
                 ,1508007,0604101,11647857,0595971,11649949,0601842,11649005,0594175,11650172,060
                 6193,140022120,09074332,12230476,0628472
                 """
                 |> IRSignalSupport.decompress()

  @sample_packet """
                 14504582,0623805,1508711,0596249,1539304,0600213,1537155,0597361,1539840,0616861
                 ,1521174,0596249,1541767,0595194,1538637,0598286,1539063,0598083,11652486,060249
                 0,11672024,0570508,11690801,0569601,11642597,0600823,11648431,0600360,11655339,0
                 588212,11652893,0599490,11650172,0593878,1538360,0630138,1506211,0599860,1165300
                 5,0600453,11648912,0624417,1508340,0597786,1537915,0630917,1505636,0600212,15358
                 41,0603824,11645023,0627472,11622856,0598953,1534174,0628194,1508007,0604101,116
                 47857,0595971,11649949,0601842,11649005,0594175,11650172,0606193,140022120
                 """
                 |> IRSignalSupport.decompress()

  describe "parse/1" do
    test "sanity checks values" do
      assert_raise(RuntimeError, fn ->
        Subject.parse([{0, 10}])
      end)
    end

    test "on real data" do
      actual = Subject.parse(@sample_signal)
      expected = [{:ok, <<0, 255, 48, 207>>}]
      assert actual == expected
    end
  end

  describe "group_into_packets/1" do
    test "on simple data" do
      actual =
        Subject.group_into_packets([
          {1, 1},
          {2, 0},
          {3, 1},
          # Packet start
          {8_700_000, 0},
          # Packet second bit
          {4_500_760, 1},
          {4, 1},
          {5, 0},
          {6, 1},
          # Packet end
          {9_300_000, 0},
          {7, 1},
          # Packet start
          {9_000_000, 0},
          # Note absence of packet second bit
          {8, 1},
          # Packet end
          {9_000_000, 0},
          {9, 1},
          {10, 0},
          {11, 1}
        ])

      expected = [
        [
          {4, 1},
          {5, 0},
          {6, 1}
        ]
      ]

      assert actual == expected
    end

    test "on real data has correct number" do
      actual = Subject.group_into_packets(@sample_signal)
      assert length(actual) == 1
    end
  end

  describe "packet_convert_to_valley_durations/1" do
    test "on simple data" do
      actual =
        Subject.packet_convert_to_valley_durations([
          {1, 1},
          # Perfect duration pulse
          {600_000, 0},
          {2, 1},
          # Pulse near upper tolerance
          {650_000, 0},
          {3, 1},
          # Pulse near lower tolerance
          {580_000, 0},
          {4, 1},
          # Pulse above upper tolerance
          {800_000, 0},
          {5, 1},
          # Pulse below lower tolerance
          {400_000, 0},
          {6, 1}
        ])

      expected = [
        1,
        2,
        3,
        4,
        {:unrecognized_pulse, 800_000},
        5,
        {:unrecognized_pulse, 400_000},
        6
      ]

      assert actual == expected
    end

    test "on real data finds no unrecognized pulses" do
      actual = Subject.packet_convert_to_valley_durations(@sample_packet)
      assert not Enum.any?(actual, &(&1 == :unrecognized_pulse))
    end
  end

  describe "packet_convert_valley_durations_to_bits/1" do
    test "on simple data" do
      actual =
        Subject.packet_convert_valley_durations_to_bits([
          # Exactly 1
          550_000,
          # Slightly above 1
          560_000,
          # Slightly below 1
          540_000,
          # Around 3 (level of inaccuracy based on real data)
          610_000 * 3
        ])

      expected = [0, 0, 0, 1]

      assert actual == expected
    end

    test "passes through unrecognized pulses" do
      actual = Subject.packet_convert_valley_durations_to_bits([:unrecognized_pulse])
      expected = [:unrecognized_pulse]
      assert actual == expected
    end
  end
end
