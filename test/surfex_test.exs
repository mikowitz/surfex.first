defmodule SurfexTest do
  use ExUnit.Case
  doctest Surfex

  # test "load a simple wav" do
  #   file = Surfex.WavFile.read("priv/samples/CantinaBand3.wav")
  #
  #   assert file.audio_format == 1
  #   assert file.num_channels == 1
  #   assert file.bits_per_sample == 16
  #   assert file.sample_rate == 22050
  #   # frames * 2 bytes per
  #   assert byte_size(file.data) == 66150 * 2
  # end
  #
  # test "load a stero wav" do
  #   file = Surfex.WavFile.read("priv/samples/pcm1622s.wav")
  #
  #   assert file.audio_format == 1
  #   assert file.num_channels == 2
  #   assert file.bits_per_sample == 16
  #   assert file.sample_rate == 22050
  #   # frames * channels * 2 bytes per
  #   assert byte_size(file.data) == 147_455 * 4
  # end
  #
  # test "load a non PCM wav" do
  #   file = Surfex.WavFile.read("priv/samples/7dot1.wav")
  #
  #   assert file.audio_format == 0xFFFE
  #   assert file.num_channels == 8
  #   assert file.bits_per_sample == 24
  #   assert file.sample_rate == 48000
  #   # frames * channels * 3 bytes per
  #   assert byte_size(file.data) == 434_386 * 8 * 3
  # end
end
