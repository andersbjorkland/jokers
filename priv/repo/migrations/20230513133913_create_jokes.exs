defmodule Jokers.Repo.Migrations.CreateJokes do
  use Ecto.Migration

  def change do
    create table(:jokes) do
      add :text, :text
      add :likes, :integer
      add :dislikes, :integer

      timestamps()
    end
  end
end
