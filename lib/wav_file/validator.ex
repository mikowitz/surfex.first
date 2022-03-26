defmodule Surfex.WavFile.Validator do
  def validate(data) do
    if validate_block_align(data) && validate_bits_per_sample(data) do
      {:ok, data}
    else
      {:error, :cant_validate_wav_data}
    end
  end

  def validate_block_align(data) do
    data.block_align == data.bits_per_sample * data.num_channels / 8
  end

  def validate_bits_per_sample(data) do
    data.bytes_per_sec == data.sample_rate * data.num_channels * data.bits_per_sample / 8
  end
end
