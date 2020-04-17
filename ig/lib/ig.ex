defmodule Ig do
  @moduledoc """
  Documentation for Ig.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Ig.hello
      :world

  """
  def hello do
    :world
  end

  def h do
    prepare(
      "shbid=5454; mid=Wz25jAAEAAGSW7A4wu3FkvPwy-bb; mcd=3; fbm_124024574287414=base_domain=.instagram.com; ig_cb=1; rur=PRN; csrftoken=mLjLJmbMi2j5k0dBXvgeyylZumxQtoEv; ds_user_id=800921105; sessionid=IGSCbfbbaececec547aaa6b0e7b591ad021a80b596ebe8187837efaf2a72e6160412%3AKAKtTpZHVFnriQ6iBMtHiJgR12SAnyXA%3A%7B%22_auth_user_id%22%3A800921105%2C%22_auth_user_backend%22%3A%22accounts.backends.CaseInsensitiveModelBackend%22%2C%22_auth_user_hash%22%3A%22%22%2C%22_platform%22%3A4%2C%22_token_ver%22%3A2%2C%22_token%22%3A%22800921105%3AnafmRA6yVITAcLjWi5qvlXOtkRvxPQbj%3Af23657269e3e778ce38faf596f0491974a07a967324ebf620a9be31aab2306fb%22%2C%22last_refreshed%22%3A1530810082.1845674515%7D; fbsr_124024574287414=JnxoC2PEh-UmFF3akTnJoa1_CHOjTMgzLH8rLvaGJNg.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImNvZGUiOiJBUURNSU9hWHM1dVc5ZVVTMlpScFpvWlVuTWp0QlJWY1FQeGJiaEptcnRTNGtVbDJpUVpNNVpwVG5UbVliWS12TEpnaDgyRDJVLXNnZ0VnRFVRYzdwSUFtX1M2M2ZESFlsX3B1eEZKWW5nU0lhU3pRS0s5azBONktsU3lJNkpzUnNjT2VxWWxnbGJONkgzSEZmNHhwZXlESkZDMG1Fb2hENWlnVzJ1T3ExRUhkNUxPX0dpNXdCeXdGdEZESDhiaDRNeHJIOXlqVlRmN1dIRUV5T2JLVDNEcUhqb2ZycmdKS3h4bmVUWGpDcEVvdXYxVFJad19yOUhwWWY1T1N2ZjZfc01zM0tnMThxd19TQkRJb2xPazgtNFU4dldyR3F4Q29zZzd2VFpMQzRwV0YxblQzT29XWFZWZ2xxZkhDaHBJNld2R24ya0ZsYzl3WFdyckVnbGJMajhsQyIsImlzc3VlZF9hdCI6MTUzMDgxMTY1NSwidXNlcl9pZCI6IjEwMDAwMDIzMzI5MDU5OSJ9; shbts=1530812233.3882718; urlgen=\"{\"time\": 1530771852}:1fb8Jf:4-rcpSVsvut76GO_5UACmbnpa2Y\""
    )
  end

  def prepare(cookie) do
    Ig.Scraper.set_cookie(cookie)
  end

  def change_profile(profile) do
    Ig.Scraper.prepare_scrape(profile)
  end

  def draw() do
    {:ok, %{profile_name: profile_name}} = Ig.Scraper.state()
    Ig.ImageMagick.draw(profile_name)
  end

  defp inner_scrape() do
    {:ok, %{has_next_page: has_next_page, is_private: is_private}} = Ig.Scraper.state()

    cond do
      is_private ->
        IO.puts("This profile is private, you cannot scrape it")

      has_next_page ->
        IO.puts("Scraping")
        Ig.Scraper.scrape_profile()
        inner_scrape()

      has_next_page == false ->
        IO.puts("Scraping")
        Ig.Scraper.scrape_profile()
        IO.puts("Finished")
    end
  end

  def scrape(profile) do
    IO.puts("Preparing Profile")
    Ig.Scraper.prepare_scrape(profile)
    Ig.Scraper.initial_scrape()
    inner_scrape()
  end

  def download(post, profile_name, timestamp) do
    case Ig.Parser.parse(post) do
      {:ok, picture_url} -> Ig.Downloader.download(picture_url, profile_name, timestamp)
      {:error, ""} -> "Some error"
    end
  end
end
