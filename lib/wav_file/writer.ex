defmodule Surfex.WavFile.Writer do
  import Surfex.ParsingMacros

  @wav_format_extensible 0xFFFE

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
    <<
      "RIFF"::binary,
      filesize(file)::l32(),
      "WAVE"::binary
    >>
  end

  def fmt_header(file) do
    <<
      "fmt "::binary,
      fmt_chunk_size(file)::l32(),
      file.fmt_code::l16()
    >>
  end

  def fmt_data(%{fmt_code: 1} = file) do
    shared_format_data(file)
  end

  def fmt_data(%{fmt_code: @wav_format_extensible} = file) do
    <<
      shared_format_data(file)::binary,
      22::l16(),
      file.valid_bits_per_sample::l16(),
      file.channel_mask::l32(),
      file.subformat::bytes-size(16)
    >>
  end

  def fmt_data(file) do
    <<
      shared_format_data(file)::binary,
      0::l16()
    >>
  end

  defp shared_format_data(file) do
    <<
      file.num_channels::l16(),
      file.sample_rate::l32(),
      file.bytes_per_sec::l32(),
      file.block_align::l16(),
      file.bits_per_sample::l16()
    >>
  end

  def fact_data(%{fmt_code: 1}), do: <<>>

  def fact_data(%{fmt_code: @wav_format_extensible} = file) do
    case file.subformat do
      <<1::l16(), _::binary>> -> <<>>
      _ -> shared_fact_data(file)
    end
  end

  def fact_data(file) do
    shared_fact_data(file)
  end

  defp shared_fact_data(file) do
    sample_length = round(file.data_size / file.num_channels)

    <<"fact"::binary, 4::l32(), sample_length::l32()>>
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

  def filesize(file) do
    4 + fmt_chunk_size(file) + 8 + fact_chunk_size(file) + 8 + byte_size(file.data)
  end

  def fmt_chunk_size(%{fmt_code: 1}), do: 16
  def fmt_chunk_size(%{fmt_code: @wav_format_extensible}), do: 40
  def fmt_chunk_size(_), do: 18

  def fact_chunk_size(%{fmt_code: 1}), do: 0

  def fact_chunk_size(%{fmt_code: @wav_format_extensible, subformat: subformat}) do
    case subformat do
      <<1::l16(), _::binary>> -> 0
      _ -> 12
    end
  end

  def fact_chunk_size(_), do: 12
end
