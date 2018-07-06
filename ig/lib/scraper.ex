defmodule Ig.Scraper do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(
      __MODULE__,
      %{cookie: nil, profile_id: nil, profile_name: "", has_next_page: false, end_cursor: nil},
      name: __MODULE__
    )
  end

  def state(), do: GenServer.call(__MODULE__, {:state})

  def handle_call({:state}, from, state), do: {:reply, {:ok, state}, state}

  def set_cookie(cookie), do: GenServer.call(__MODULE__, {:set_cookie, cookie})

  def handle_call({:set_cookie, cookie}, from, state) do
    new_state = state |> Map.merge(%{cookie: cookie})
    {:reply, {:ok, new_state}, new_state}
  end

  def prepare_scrape(profile_name),
    do: GenServer.call(__MODULE__, {:prepare_scrape, profile_name})

  def handle_call({:prepare_scrape, profile_name}, from, state) do
    %HTTPoison.Response{body: body, status_code: status_code} =
      HTTPoison.get!("https://www.instagram.com/#{profile_name}/")

    case status_code do
      200 -> get_info_from_profile(body, state |> Map.merge(%{ profile_name: profile_name }))
      _ -> {:reply, {:error, "Could not scrape profile"}, state}
    end
  end

  def scrape_profile, do: GenServer.call(__MODULE__, {:scrape_profile}, :infinity)

  def handle_call({:scrape_profile}, from, state) do
    %HTTPoison.Response{body: body} =
      HTTPoison.get!(
        "https://www.instagram.com/graphql/query/?query_id=17888483320059182&variables={\"id\":\"#{
          state[:profile_id]
        }\",\"first\":12,\"after\":\"#{state[:end_cursor]}\"}",
        %{},
        hackney: [cookie: state[:cookie]]
      )
    profile =
      body
      |> JSON.decode!()
      |> Map.fetch!("data")
      |> Map.fetch!("user")
      |> Map.fetch!("edge_owner_to_timeline_media")
    profile
    |> Map.fetch!("edges")
    |> Enum.each(fn x ->
      short_code = x |> Map.fetch!("node") |> Map.fetch!("shortcode")

      Task.start(fn ->
        Ig.download(
          short_code,
          state |> Map.fetch!(:profile_name),
          x |> Map.fetch!("node") |> Map.fetch!("taken_at_timestamp")
        )
      end)
    end)

    temp_state = %{
      has_next_page:
        profile
        |> Map.fetch!("page_info")
        |> Map.fetch!("has_next_page"),
      end_cursor:
        profile
        |> Map.fetch!("page_info")
        |> Map.fetch!("end_cursor")
    }

    new_state = Map.merge(state, temp_state)
    {:reply, {:ok, new_state}, new_state}
  end

  defp get_info_from_profile(body, state) do
    user =
      body
      |> String.split("<script type=\"text/javascript\">window._sharedData = ")
      |> List.last()
      |> String.split(";</script>")
      |> List.first()
      |> JSON.decode!()
      |> Map.fetch!("entry_data")
      |> Map.fetch!("ProfilePage")
      |> List.first()
      |> Map.fetch!("graphql")
      |> Map.fetch!("user")

    temp = %{
      profile_id:
        user
        |> Map.fetch!("id"),
      has_next_page:
        user
        |> Map.fetch!("edge_owner_to_timeline_media")
        |> Map.fetch!("page_info")
        |> Map.fetch!("has_next_page"),
      end_cursor:
        user
        |> Map.fetch!("edge_owner_to_timeline_media")
        |> Map.fetch!("page_info")
        |> Map.fetch!("end_cursor"),
      is_private:
        user
        |> Map.fetch!("is_private")
    }

    new_state = state |> Map.merge(temp)

    {:reply, {:ok, new_state}, new_state}
  end
end
