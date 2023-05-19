defmodule Jokers.JokesTest do
  use Jokers.DataCase

  alias Jokers.Jokes

  describe "jokes" do
    alias Jokers.Jokes.Joke

    import Jokers.JokesFixtures

    @invalid_attrs %{dislikes: nil, likes: nil, text: nil}

    test "list_jokes/0 returns all jokes" do
      joke = joke_fixture()
      assert Jokes.list_jokes() == [joke]
    end

    test "get_joke!/1 returns the joke with given id" do
      joke = joke_fixture()
      assert Jokes.get_joke!(joke.id) == joke
    end

    test "create_joke/1 with valid data creates a joke" do
      valid_attrs = %{dislikes: 42, likes: 42, text: "some text"}

      assert {:ok, %Joke{} = joke} = Jokes.create_joke(valid_attrs)
      assert joke.dislikes == 42
      assert joke.likes == 42
      assert joke.text == "some text"
    end

    test "create_joke/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jokes.create_joke(@invalid_attrs)
    end

    test "update_joke/2 with valid data updates the joke" do
      joke = joke_fixture()
      update_attrs = %{dislikes: 43, likes: 43, text: "some updated text"}

      assert {:ok, %Joke{} = joke} = Jokes.update_joke(joke, update_attrs)
      assert joke.dislikes == 43
      assert joke.likes == 43
      assert joke.text == "some updated text"
    end

    test "update_joke/2 with invalid data returns error changeset" do
      joke = joke_fixture()
      assert {:error, %Ecto.Changeset{}} = Jokes.update_joke(joke, @invalid_attrs)
      assert joke == Jokes.get_joke!(joke.id)
    end

    test "delete_joke/1 deletes the joke" do
      joke = joke_fixture()
      assert {:ok, %Joke{}} = Jokes.delete_joke(joke)
      assert_raise Ecto.NoResultsError, fn -> Jokes.get_joke!(joke.id) end
    end

    test "change_joke/1 returns a joke changeset" do
      joke = joke_fixture()
      assert %Ecto.Changeset{} = Jokes.change_joke(joke)
    end
  end
end
