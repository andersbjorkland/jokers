defmodule JokersWeb.JokeControllerTest do
  use JokersWeb.ConnCase

  import Jokers.JokesFixtures

  alias Jokers.Jokes.Joke

  @create_attrs %{
    dislikes: 42,
    likes: 42,
    text: "some text"
  }
  @update_attrs %{
    dislikes: 43,
    likes: 43,
    text: "some updated text"
  }
  @invalid_attrs %{dislikes: nil, likes: nil, text: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all jokes", %{conn: conn} do
      conn = get(conn, ~p"/api/jokes")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create joke" do
    test "renders joke when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/jokes", joke: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/jokes/#{id}")

      assert %{
               "id" => ^id,
               "dislikes" => 42,
               "likes" => 42,
               "text" => "some text"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/jokes", joke: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update joke" do
    setup [:create_joke]

    test "renders joke when data is valid", %{conn: conn, joke: %Joke{id: id} = joke} do
      conn = put(conn, ~p"/api/jokes/#{joke}", joke: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/jokes/#{id}")

      assert %{
               "id" => ^id,
               "dislikes" => 43,
               "likes" => 43,
               "text" => "some updated text"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, joke: joke} do
      conn = put(conn, ~p"/api/jokes/#{joke}", joke: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete joke" do
    setup [:create_joke]

    test "deletes chosen joke", %{conn: conn, joke: joke} do
      conn = delete(conn, ~p"/api/jokes/#{joke}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/jokes/#{joke}")
      end
    end
  end

  defp create_joke(_) do
    joke = joke_fixture()
    %{joke: joke}
  end
end
