defmodule JokersWeb.JokeJSON do
  alias Jokers.Jokes.Joke

  @doc """
  Renders a list of jokes.
  """
  def index(%{jokes: jokes}) do
    %{data: for(joke <- jokes, do: data(joke))}
  end

  @doc """
  Renders a single joke.
  """
  def show(%{joke: joke}) do
    %{data: data(joke)}
  end

  defp data(%Joke{} = joke) do
    %{
      id: joke.id,
      text: joke.text,
      likes: joke.likes,
      dislikes: joke.dislikes
    }
  end
end
