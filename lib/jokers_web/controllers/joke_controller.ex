defmodule JokersWeb.JokeController do
  use JokersWeb, :controller

  alias Jokers.Jokes
  alias Jokers.Jokes.Joke

  @topic "jokes"

  action_fallback JokersWeb.FallbackController

  def index(conn, _params) do
    jokes = Jokes.list_jokes()
    render(conn, :index, jokes: jokes)
  end

  def create(conn, %{"joke" => joke_params}) do
    with {:ok, %Joke{} = joke} <- Jokes.create_joke(joke_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/jokes/#{joke}")
      |> render(:show, joke: joke)
    end
  end

  def show(conn, %{"id" => id}) do
    joke = Jokes.get_joke!(id)
    render(conn, :show, joke: joke)
  end

  def update(conn, %{"id" => id, "joke" => joke_params}) do
    joke = Jokes.get_joke!(id)

    with {:ok, %Joke{} = joke} <- Jokes.update_joke(joke, joke_params) do
      render(conn, :show, joke: joke)
    end
  end

  def delete(conn, %{"id" => id}) do
    joke = Jokes.get_joke!(id)

    with {:ok, %Joke{}} <- Jokes.delete_joke(joke) do
      send_resp(conn, :no_content, "")
    end
  end

  def like(conn, %{"id" => id}) do
    joke = Jokes.get_joke!(id)

    likes = joke.likes + 1
    joke_params = %{likes: likes}

    {:ok, joke_updated} = Jokes.update_joke(joke, joke_params)

    state = %{joke: joke_updated}

    JokersWeb.Endpoint.broadcast(@topic, "update_joke", state)

    with {:ok, joke_updated}  do
      render(conn, :show, joke: joke_updated)
    end
  end

  def dislike(conn, %{"id" => id}) do
    joke = Jokes.get_joke!(id)

    dislikes = joke.dislikes + 1
    joke_params = %{dislikes: dislikes}

    with {:ok, %Joke{} = joke} <- Jokes.update_joke(joke, joke_params) do
      render(conn, :show, joke: joke)
    end
  end
end
