defmodule Ig.Downloader do
  def download(picture_url, dir, timestamp) do
    path = "#{File.cwd!()}/pictures/#{dir}"
    File.mkdir(path)

    case Download.from(
           picture_url,
           path:
             "#{path}/#{timestamp}_#{
               picture_url
               |> String.split("/")
               |> List.last()
               |> String.split(".jpg")
               |> List.first()
             }.jpg"
         ) do
      {:ok, picture_location} ->
        IO.puts("Downloaded to #{picture_location}")

      {:error, message} ->
        case message do
          :eexist -> IO.puts("This picture has been already downloaded.")
          _ -> IO.puts("Error - #{message}")
        end

      {:error, message, code} ->
        IO.puts("Error - #{message} - #{code}")
    end
  end
end
