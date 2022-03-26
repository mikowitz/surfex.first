defmodule Surfex.WavFile.Writer do
  import Surfex.ParsingMacros

  def write(file, filename) do
    data = <<
      riff_header(file)::binary,
      fmt_header(file)::binary,
      fmt_data(file)::binary,
      fact_data(file)::binary,
      audio_data(file)::binary
    >>

    File.write(filename, data)
  end

  def riff_header(file) do
    filesize = filesize(file)

    <<
      "RIFF"::binary,
      filesize::l32(),
      "WAVE"::binary
    >>
  end

  def fmt_header(file) do
    chunk_size =
      case file.fmt_code do
        1 -> 16
        0xFFFE -> 40
        _ -> 18
      end

    <<
      "fmt "::binary,
      chunk_size::l32(),
      file.fmt_code::l16()
    >>
  end

  def fmt_data(%{fmt_code: 1} = file) do
    <<
      file.num_channels::l16(),
      file.sample_rate::l32(),
      file.bytes_per_sec::l32(),
      file.block_align::l16(),
      file.bits_per_sample::l16()
    >>
  end

  def fmt_data(%{fmt_code: 0xFFFE} = file) do
    <<
      file.num_channels::l16(),
      file.sample_rate::l32(),
      file.bytes_per_sec::l32(),
      file.block_align::l16(),
      file.bits_per_sample::l16(),
      22::l16(),
      file.valid_bits_per_sample::l16(),
      file.channel_mask::l32(),
      file.subformat::bytes-size(16)
    >>
  end

  def fmt_data(file) do
    <<
      file.num_channels::l16(),
      file.sample_rate::l32(),
      file.bytes_per_sec::l32(),
      file.block_align::l16(),
      file.bits_per_sample::l16(),
      0::l16()
    >>
  end

  def fact_data(%{fmt_code: 1}), do: <<>>

  def fact_data(%{fmt_code: 0xFFFE} = file) do
    <<format::l16(), _::binary>> = file.subformat

    case format do
      1 ->
        <<>>

      _ ->
        sample_length = round(file.data_size / file.num_channels)

        <<
          "fact"::binary,
          4::l32(),
          sample_length::l32()
        >>
    end
  end

  def fact_data(file) do
    sample_length = round(file.data_size / file.num_channels)

    <<
      "fact"::binary,
      4::l32(),
      sample_length::l32()
    >>
  end

  def audio_data(file) do
    size = byte_size(file.data)

    pad =
      case rem(size, 2) do
        0 -> <<>>
        1 -> <<0>>
      end

    <<
      "data"::binary,
      file.data_size::l32(),
      file.data::binary,
      pad::binary
    >>
  end

  def filesize(%{fmt_code: 1} = file), do: 4 + 24 + 8 + file.data_size
  def filesize(%{fmt_code: 0xFFFE} = file), do: 4 + 48 + 12 + 8 + file.data_size
  def filesize(file), do: 4 + 26 + 12 + 8 + file.data_size
end
