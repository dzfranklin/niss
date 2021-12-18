defmodule Niss.Repo.Migrations.CreatePhoneTexts do
  use Ecto.Migration

  def change do
    create table(:phone_texts) do
      add :message_sid, :text, null: false
      add :from_number, :text, null: false
      add :to_number, :text, null: false
      add :body, :text, null: false
      add :from_city, :text
      add :from_state, :text
      add :from_zip, :text
      add :from_country, :text

      timestamps()
    end

    create unique_index(:phone_texts, [:message_sid])
    create index(:phone_texts, [:from_number])
    create index(:phone_texts, [:to_number])
  end
end
