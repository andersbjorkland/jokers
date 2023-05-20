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

    dislikes = if (socket_joke.has_disliked) do
      joke.dislikes - 1
    else
      joke.dislikes
    end

    {:ok, joke} = Jokers.Jokes.update_joke(joke, %{likes: likes, dislikes: dislikes })
    state = %{joke: %{socket_joke | likes: joke.likes, dislikes: joke.dislikes }, sender: self()}

    JokersWeb.Endpoint.broadcast(socket.assigns.topic, "update_like", state)

    {:noreply, socket}
  end

  def handle_event("dislike_joke", %{"joke_id" => joke_id} = _params, socket) do

    {joke_id, _} = Integer.parse(joke_id)
    joke = Jokers.Jokes.Joke |> Jokers.Repo.get(joke_id)

    socket_jokes = socket.assigns.jokes
    [socket_joke | _rest ] = Enum.filter(socket_jokes, &(&1.id == joke_id))

    dislikes = if (socket_joke.has_disliked) do
      joke.dislikes - 1
    else
      joke.dislikes + 1
    end

    likes = if (socket_joke.has_liked) do
      joke.likes - 1
    else
      joke.likes
    end

    {:ok, joke} = Jokers.Jokes.update_joke(joke, %{likes: likes, dislikes: dislikes })
    state = %{
      joke: %{socket_joke | likes: joke.likes, dislikes: joke.dislikes},
      sender: self()
    }

    JokersWeb.Endpoint.broadcast(socket.assigns.topic, "update_dislike", state)

    {:noreply, socket}
  end

  def handle_info(%{topic: "jokes", event: "update_like", payload: %{joke: joke, sender: sender}}, socket) do
    joke = if (sender == self()) do
      joke = %{joke | has_liked: !joke.has_liked}
      if (joke.has_disliked) do
        %{joke | has_disliked: false}
      else
        joke
      end
    else
      [socket_joke | _rest ] = Enum.filter(socket.assigns.jokes, &(&1.id == joke.id))
      %{joke | has_liked: socket_joke.has_liked, has_disliked: socket_joke.has_disliked }
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

  def handle_info(%{topic: "jokes", event: "update_dislike", payload: %{joke: joke, sender: sender}}, socket) do
    joke = if (sender == self()) do
      joke = %{joke | has_disliked: !joke.has_disliked}
      if (joke.has_disliked) do
        %{joke | has_liked: false}
      else
        joke
      end
    else
      [socket_joke | _rest ] = Enum.filter(socket.assigns.jokes, &(&1.id == joke.id))
      %{joke | has_liked: socket_joke.has_liked, has_disliked: socket_joke.has_disliked }
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
