defmodule Niss.Possessions do
  @moduledoc """
  The Possessions context.
  """

  import Ecto.Query, warn: false
  alias Niss.Repo
  require Logger

  alias Niss.Possessions.Possession
  alias Possession.Image

  @config Application.fetch_env!(:niss, Niss.Possessions)
  @image_dir Keyword.fetch!(@config, :image_dir)

  def filesystem_image_dir, do: @image_dir

  def list_possessions do
    Repo.all(Possession)
  end

  def get_possession!(id), do: Repo.get!(Possession, id)

  def create_possession(attrs \\ %{}) do
    %Possession{}
    |> Possession.changeset(attrs)
    |> Repo.insert()
  end

  def update_possession(%Possession{} = possession, attrs) do
    possession
    |> Possession.changeset(attrs)
    |> Repo.update()
  end

  def delete_possession(%Possession{} = possession) do
    Repo.delete(possession)
  end

  def change_possession(%Possession{} = possession, attrs \\ %{}) do
    Possession.changeset(possession, attrs)
  end

  def set_image!(%Possession{} = possession, upload_path) do
    id = Ecto.UUID.generate()

    tasks = [
      Task.async(fn -> convert_upload_img!(upload_path, "50x50") end),
      Task.async(fn -> convert_upload_img!(upload_path, "250x250") end),
      Task.async(fn -> convert_upload_img!(upload_path, "1000x1000") end)
    ]

    [icon_path, preview_path, full_path] = Task.await_many(tasks, 10_000)
    File.rm!(upload_path)

    save_img_variant!(icon_path, id, "icon")
    save_img_variant!(preview_path, id, "preview")
    save_img_variant!(full_path, id, "full")

    Repo.transaction(fn ->
      Image.changeset(%{id: id})
      |> Repo.insert!()

      Possession.changeset(possession, %{image_id: id})
      |> Repo.update!()
    end)
  end

  defp convert_upload_img!(upload_path, limit_size) do
    import Mogrify

    image =
      open(upload_path)
      |> resize_to_limit(limit_size)
      |> format("jpeg")
      |> save()

    image.path
  end

  defp save_img_variant!(path, id, variant) do
    name = "v1_#{id}_#{variant}.jpeg"
    dest_path = Path.join([@image_dir, name])
    File.rename!(path, dest_path)
  end
end
