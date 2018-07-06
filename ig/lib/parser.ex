defmodule Ig.Parser do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def parse(post_key), do: GenServer.call(__MODULE__, {:parse, post_key}, :infinity)

  def handle_call({:parse, post_key}, from, state) do
    resp = state |> Map.get(post_key)

    case resp do
      nil ->
        %HTTPoison.Response{body: body} =
          HTTPoison.get!("https://www.instagram.com/p/#{post_key}/")

        picture_url =
          body
          |> Floki.find("meta[property='og:image']")
          |> Floki.attribute("content")
          |> List.first()

        {:reply, {:ok, picture_url}, state |> Map.put_new(post_key, picture_url)}

      _ ->
        {:reply, {:ok, resp}, state}
    end
  end
end
