defmodule UrlsTest do
  use ExUnit.Case
  alias ExUnit.Assertions
  require Logger

  @po_file_path "priv/gettext/es/LC_MESSAGES/default.po"
  @regex ~r/(http|https):\/\/[^\s\"\'\]\)]+/

  test "check URLs" do
    File.read!(@po_file_path)
    |> extract_urls()
    |> Task.async_stream(&validate_and_check_url/1, max_concurrency: 10, timeout: 10_000)
    |> Enum.each(fn
      {:ok, true} -> :ok
      {:ok, false} -> Assertions.flunk("Some URLs failed the check.")
      {:exit, _} -> Assertions.flunk("Task exited unexpectedly.")
      {:error, reason} -> Assertions.flunk("Task failed: #{reason}")
    end)
  end

  defp extract_urls(content) do
    Regex.scan(@regex, content)
    |> List.flatten()
    |> Enum.uniq()
  end

  defp validate_and_check_url(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host} when scheme in ["http", "https"] and not is_nil(host) ->
        check_url(url)
      _ ->
        Logger.warning("Invalid URL found: #{url}")
        true
    end
  end

  defp check_url(url) do
    case HTTPoison.get(url, [], recv_timeout: 5000) do
      {:ok, %HTTPoison.Response{status_code: code}} when code in 200..399 ->
        true
      {:ok, %HTTPoison.Response{status_code: code}} ->
        Logger.error("Error with URL #{url}: Returned status code: #{code}")
        false
      {:error, %HTTPoison.Error{reason: :timeout}} ->
        Logger.warning("Timeout for URL #{url}")
        false
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Error with URL #{url}: Failed to fetch URL: #{reason}")
        false
    end
  end
end
