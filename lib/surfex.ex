defmodule Surfex do
  import Surfex.ParsingMacros

  def lower_volume(infile, outfile) do
    in_data = Surfex.WavFile.read(infile)

    audio_data =
      Enum.map(in_data.data, fn x -> round(x * 0.5) end)
      |> Enum.map(fn i -> <<i::ls16()>> end)
      |> Enum.reduce(<<>>, fn d, acc -> acc <> d end)

    audio_size = byte_size(audio_data)

    filesize = 36 + audio_size

    new_sample_rate = round(in_data.sample_rate / 4)
    new_byte_rate = round(new_sample_rate * in_data.bits_per_sample * in_data.num_channels / 8)

    IO.inspect([new_sample_rate, new_byte_rate])

    file_data = <<
      "RIFF"::binary,
      filesize::l32(),
      "WAVE"::binary,
      "fmt "::binary,
      16::l32(),
      in_data.audio_format::l16(),
      in_data.num_channels::l16(),
      new_sample_rate::l32(),
      new_byte_rate::l32(),
      in_data.block_align::l16(),
      in_data.bits_per_sample::l16(),
      "data"::binary,
      audio_size::l32(),
      audio_data::binary
    >>

    File.write(outfile, file_data)
  end
end
