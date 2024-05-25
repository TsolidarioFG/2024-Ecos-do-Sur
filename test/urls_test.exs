defmodule UrlsTest do
  use ExUnit.Case
  alias ExUnit.Assertions
  require Logger

  @po_file_path "priv/gettext/es/LC_MESSAGES/default.po"
  @regex ~r/(http|https):\/\/[^\s\"\'\]\)]+/

  test "check URLs" do
    extract_urls(File.read!(@po_file_path))
    |> Enum.each(&validate_and_check_url/1)
  end

  defp extract_urls(content) do
    Regex.scan(@regex, content)
    |> List.flatten()
    |> Enum.uniq()
  end

  defp validate_and_check_url(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host} when scheme in ["http", "https"] and not is_nil(host) ->
        try do
          check_url(url)
        rescue
          _ in Protocol.UndefinedError -> :ok
          message -> Assertions.flunk("Error with URL #{url}: #{message.message}") # Ignore any certificate or unexpected errors.
        end
      _ ->
        Logger.warning("Invalid URL found: #{url}")
    end
  end

  defp check_url(url) do
    case HTTPoison.get(url, [], recv_timeout: 5000) do
      {:ok, %HTTPoison.Response{status_code: code}} when code in 200..399 ->
        :ok
      {:ok, %HTTPoison.Response{status_code: code}} ->
        log_and_fail(url, "Returned status code: #{code}")
      {:error, %HTTPoison.Error{reason: :timeout}} ->
        Logger.warning("Timeout for URL #{url}")
      {:error, %HTTPoison.Error{reason: reason}} ->
        log_and_fail(url, "Failed to fetch URL: #{reason}")
    end
  end

  defp log_and_fail(url, message) do
    Logger.error("Error with URL #{url}: #{message}")
    raise message
  end
end
