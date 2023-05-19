defmodule JokersWeb.Live.Home do
  use JokersWeb, :live_view
  require Logger


  def mount(_params, _session, socket) do
    topic = "jokes"

    if connected?(socket) do
      JokersWeb.Endpoint.subscribe(topic)
    end

    joke = Jokers.Jokes.Joke |> Ecto.Query.first |> Jokers.Repo.one
    jokes = Jokers.Jokes.Joke |> Jokers.Repo.all(limit: 2)

    socket = assign(socket, :joke, joke)
      |>assign(:topic, topic)
      |>assign(:jokes, jokes)

      {:ok, socket}
  end

  def handle_event("increment", _params, socket) do
    joke = socket.assigns.joke

    {:ok, joke} = Jokers.Jokes.update_joke(joke, %{likes: joke.likes + 1})

    state = %{joke: joke}
    JokersWeb.Endpoint.broadcast(socket.assigns.topic, "increment_joke", state)

    {:noreply, assign(socket, joke: joke)}
  end

  def handle_event("like_joke", %{"joke_id" => joke_id} = params, socket) do
    Logger.info(params)
    {joke_id, _} = Integer.parse(joke_id)
    joke = Jokers.Jokes.Joke |> Jokers.Repo.get(joke_id)

    {:ok, joke} = Jokers.Jokes.update_joke(joke, %{likes: joke.likes + 1})

    state = %{joke: joke}
    JokersWeb.Endpoint.broadcast(socket.assigns.topic, "update_joke", state)

    jokes = socket.assigns.jokes
      |> Enum.map(fn
        %Jokers.Jokes.Joke{id: ^joke_id} -> joke
        element -> element
      end)


    {:noreply, assign(socket, jokes: jokes)}
  end

  def handle_info(%{event: "update_joke", payload: %{joke: joke}}, socket) do
    joke_id = joke.id
    jokes = socket.assigns.jokes
      |> Enum.map(fn
        %Jokers.Jokes.Joke{id: ^joke_id} -> joke
        element -> element
      end)

      {:noreply, assign(socket, jokes: jokes)}
  end

  def handle_info(%{event: "increment_joke", payload: %{joke: joke}}, socket) do
    Logger.info(joke: joke)
    socket = socket
      |> assign(:joke, joke)
    {:noreply, socket}
  end
end
