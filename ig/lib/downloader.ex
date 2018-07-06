defmodule Ig.Downloader do
  def download(picture_url, profile_name) do
    path = "#{File.cwd!()}/pictures/#{profile_name}"
    File.mkdir(path)

    case Download.from(
           picture_url,
           path:
             "#{path}/#{:os.system_time(:millisecond)}_#{
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
