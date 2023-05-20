defmodule JokersWeb.Live.Home do
  use JokersWeb, :live_view
  require Logger


  def mount(_params, _session, socket) do
    topic = "jokes"

    if connected?(socket) do
      JokersWeb.Endpoint.subscribe(topic)
    end

    jokes = Jokers.Jokes.Joke |> Jokers.Repo.all(limit: 2)

    socket = socket
      |>assign(:topic, topic)
      |>assign(:jokes, jokes)

    {:ok, socket}
  end

  def handle_event("like_joke", %{"joke_id" => joke_id} = _params, socket) do

    {joke_id, _} = Integer.parse(joke_id)
    joke = Jokers.Jokes.Joke |> Jokers.Repo.get(joke_id)

    socket_jokes = socket.assigns.jokes
    [socket_joke | _rest ] = Enum.filter(socket_jokes, &(&1.id == joke_id))

    likes = if (socket_joke.has_liked) do
      joke.likes - 1
    else
      joke.likes + 1
    end

    {:ok, joke} = Jokers.Jokes.update_joke(joke, %{likes: likes })
    state = %{joke: %{socket_joke | likes: joke.likes}, sender: self()}

    JokersWeb.Endpoint.broadcast(socket.assigns.topic, "update_joke", state)

    {:noreply, socket}
  end

  def handle_info(%{topic: "jokes", event: "update_joke", payload: %{joke: joke, sender: sender}}, socket) do
    joke = if (sender == self()) do
      %{joke | has_liked: !joke.has_liked }
    else
      [socket_joke | _rest ] = Enum.filter(socket.assigns.jokes, &(&1.id == joke.id))
      %{joke | has_liked: socket_joke.has_liked }
    end

    joke_id = joke.id

    jokes =
      socket.assigns.jokes
        |> Enum.map(fn
          %Jokers.Jokes.Joke{id: ^joke_id} -> joke
          element -> element
        end)

    {:noreply, assign(socket, jokes: jokes)}
  end
end
