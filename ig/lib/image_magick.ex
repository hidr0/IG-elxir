import Mogrify

defmodule Ig.ImageMagick do
  def draw(profile_folder) do
    files =
      File.ls!("pictures/#{profile_folder}") |> Enum.filter(fn x -> x =~ "jpg" end) |> Enum.sort()

    count = files |> Enum.count() |> IO.inspect()

    sq = count |> :math.sqrt() |> Float.ceil() |> Kernel.trunc()
    size = (1080 / sq) |> Kernel.trunc()

    mog =
      %Mogrify.Image{path: "#{profile_folder}.png", ext: "png"}
      |> custom("size", "1080x1080")
      |> canvas("white")

    files
    |> Enum.reduce([], fn file, list ->
      IO.puts("Converting image")

      [
        System.cmd("convert", ["pictures/#{profile_folder}/#{file}", "-resize", "1x1", "txt:-"])
        |> elem(0)
        |> String.split("#")
        |> List.last()
        |> String.split(" ")
        |> List.first()
        | list
      ]
    end)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(mog, fn element, acc ->
      acc
      |> custom("fill", "##{elem(element, 0)}")
      |> Mogrify.Draw.rectangle(
        rem(elem(element, 1), sq) * size,
        div(elem(element, 1), sq) * size,
        rem(elem(element, 1), sq) * size + size,
        div(elem(element, 1), sq) * size + size
      )
    end)
    |> create(path: ".")
  end
end
