defmodule Jokers.Jokes.Joke do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jokes" do
    field :dislikes, :integer, default: 0
    field :likes, :integer, default: 0
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(joke, attrs) do
    joke
    |> cast(attrs, [:text, :likes, :dislikes])
    |> validate_required([:text, :likes, :dislikes])
  end
end
