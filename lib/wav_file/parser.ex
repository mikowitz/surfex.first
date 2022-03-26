defmodule Surfex.WavFile.Parser do
  import Surfex.ParsingMacros

  def parse(data) do
    {:ok, header_data, rest} = parse_riff_chunk(data)
    {:ok, fmt_code_data, rest} = parse_fmt_code(rest)
    {:ok, fmt_data, rest} = parse_fmt_data(rest, fmt_code_data.fmt_code)
    {:ok, fact_data, rest} = parse_fact_data(rest, fmt_code_data.fmt_code, fmt_data[:subformat])
    {:ok, sampled_data} = parse_sampled_data(rest)

    {:ok,
     header_data
     |> Map.merge(fmt_code_data)
     |> Map.merge(fmt_data)
     |> Map.merge(fact_data)
     |> Map.merge(sampled_data)}
  end

  def parse_riff_chunk(data) do
    <<"RIFF"::binary, filesize::l32(), "WAVE"::binary, rest::binary>> = data
    {:ok, %{filesize: filesize}, rest}
  end

  def parse_fmt_code(data) do
    <<"fmt "::binary, fmt_chunk_size::l32(), fmt_code::l16(), rest::binary>> = data
    {:ok, %{fmt_chunk_size: fmt_chunk_size, fmt_code: fmt_code}, rest}
  end

  def parse_fmt_data(data, 1) do
    <<num_channels::l16(), sample_rate::l32(), bytes_per_sec::l32(), block_align::l16(),
      bits_per_sample::l16(), rest::binary>> = data

    {:ok,
     %{
       num_channels: num_channels,
       sample_rate: sample_rate,
       bytes_per_sec: bytes_per_sec,
       block_align: block_align,
       bits_per_sample: bits_per_sample
     }, rest}
  end

  def parse_fmt_data(data, 0xFFFE) do
    <<
      num_channels::l16(),
      sample_rate::l32(),
      bytes_per_sec::l32(),
      block_align::l16(),
      bits_per_sample::l16(),
      22::l16(),
      valid_bits_per_sample::l16(),
      channel_mask::l32(),
      subformat::bytes-size(16),
      rest::binary
    >> = data

    {:ok,
     %{
       num_channels: num_channels,
       sample_rate: sample_rate,
       bytes_per_sec: bytes_per_sec,
       block_align: block_align,
       bits_per_sample: bits_per_sample,
       valid_bits_per_sample: valid_bits_per_sample,
       channel_mask: channel_mask,
       subformat: subformat
     }, rest}
  end

  def parse_fmt_data(data, _) do
    <<
      num_channels::l16(),
      sample_rate::l32(),
      bytes_per_sec::l32(),
      block_align::l16(),
      bits_per_sample::l16(),
      0::l16(),
      rest::binary
    >> = data

    {:ok,
     %{
       num_channels: num_channels,
       sample_rate: sample_rate,
       bytes_per_sec: bytes_per_sec,
       block_align: block_align,
       bits_per_sample: bits_per_sample
     }, rest}
  end

  def parse_fact_data(data, 1, _), do: {:ok, %{}, data}

  def parse_fact_data(data, 0xFFFE, subformat) do
    <<format::l16(), _::binary>> = subformat

    case format do
      1 ->
        {:ok, %{}, data}

      _ ->
        <<
          "fact"::binary,
          fact_chunk_size::l32(),
          sample_length::l32(),
          rest::binary
        >> = data

        {:ok, %{fact_chunk_size: fact_chunk_size, sample_length: sample_length}, rest}
    end
  end

  def parse_fact_data(data, _, _) do
    <<
      "fact"::binary,
      fact_chunk_size::l32(),
      sample_length::l32(),
      rest::binary
    >> = data

    {:ok, %{fact_chunk_size: fact_chunk_size, sample_length: sample_length}, rest}
  end

  def parse_sampled_data(data) do
    <<
      "data"::binary,
      data_size::l32(),
      data::binary()
    >> = data

    {:ok, %{data_size: data_size, data: data}}
  end
end
