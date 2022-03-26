defmodule Surfex.WavFile do
  import Surfex.WavFile.{Parser, Validator}

  alias Surfex.WavFile.Writer

  defstruct [
    :filesize,
    :fmt_code,
    :subformat,
    :valid_bits_per_sample,
    :num_channels,
    :sample_rate,
    :bytes_per_sec,
    :channel_mask,
    :block_align,
    :bits_per_sample,
    :data_size,
    :data,
    :parsed_data
  ]

  def read(filename) do
    with {:ok, data} <- File.read(filename),
         {:ok, wav_data} <- parse(data),
         {:ok, wav_data} <- validate(wav_data) do
      struct(__MODULE__, wav_data)
    end
  end

  def write(%__MODULE__{} = file, filename) do
    Writer.write(file, filename)
  end

  def parse_audio_data(%__MODULE__{} = file) do
    sample_size = round(file.bits_per_sample * file.num_channels / 8)
    bps = file.bits_per_sample

    samples = for <<sample::binary-size(sample_size) <- file.data>>, do: sample

    Enum.map(samples, fn sample ->
      {<<>>, channel_samples} =
        Enum.reduce(1..file.num_channels, {sample, []}, fn _, {sample, split_samples} ->
          <<ch::little-signed-size(bps), rest::binary>> = sample
          {rest, [ch | split_samples]}
        end)

      channel_samples
    end)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def restore_audio_data(split_channels, bits_per_sample) do
    split_channels
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(fn chunk ->
      Enum.map(chunk, fn s -> <<s::little-signed-size(bits_per_sample)>> end)
      |> Enum.reduce(<<>>, fn c, acc -> c <> acc end)
    end)
    |> Enum.reduce(<<>>, fn c, acc -> acc <> c end)
  end
end
