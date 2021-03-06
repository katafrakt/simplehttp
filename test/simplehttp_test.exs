defmodule SimpleHttpTest do
  use ExUnit.Case
  doctest SimpleHttp

  defmodule Test.Server do
    use Plug.Router
    require Logger

    plug Plug.Logger
    plug :match
    plug :dispatch

    def init(options) do
      options
    end

    def start_link do
      {:ok, _} = Plug.Adapters.Cowboy.http Test.Server, []
    end

    get "/" do
      conn
      |> send_resp(200, "ok")
      |> halt
    end

    post "/" do
      conn
      |> send_resp(200, "ok")
      |> halt
    end

    put "/users/1" do
      conn
      |> send_resp(200, "ok")
      |> halt
    end

    delete "/" do
      conn
      |> send_resp(200, "ok")
      |> halt
    end

  end

  defmodule Test.Supervisor do
    use Application

    def start(_type, _args) do
      import Supervisor.Spec, warn: false

      children = [
        worker(Test.Server, [])
      ]

      opts = [strategy: :one_for_one, name: Test.Supervisor]
      Supervisor.start_link(children, opts)
    end
  end

  setup_all do
    case Test.Supervisor.start([],[]) do
      {:ok, _} -> :ok
      _ -> raise "Error"
    end
  end

  test "simple get request" do
    assert {:ok, response } = SimpleHttp.get "http://localhost:4000"
    assert response.__struct__ == SimpleHttp.Response
    assert response.body == "ok"
  end

  test "simple post request" do
    assert {:ok, response } = SimpleHttp.post "http://localhost:4000", [
      params: [
        title: "title is present here",
        message: "hello world!"
      ],
      content_type: "application/x-www-form-urlencoded",
      timeout: 1000,
      connect_timeout: 1000
    ]
    assert response.__struct__ == SimpleHttp.Response
    assert response.body == "ok"
  end

  test "simple put request" do
    assert {:ok, response } = SimpleHttp.put "http://localhost:4000/users/1", [
      params: [
        title: "title is present here",
        message: "hello world!"
      ],
      content_type: "application/x-www-form-urlencoded",
      timeout: 1000,
      connect_timeout: 1000
    ]
    assert response.__struct__ == SimpleHttp.Response
    assert response.body == "ok"
  end

  test "simple delete request" do
    assert {:ok, response } = SimpleHttp.delete "http://localhost:4000"
    assert response.__struct__ == SimpleHttp.Response
    assert response.body == "ok"
  end

  test "simple get with query params" do
    assert {:ok, response} = SimpleHttp.get "http://localhost:4000/", [
      query_params: [
        postId: 1,
        title: "Alexandru Bagu"
      ]
    ]
    assert response.__struct__ == SimpleHttp.Response
  end

  test "json post" do
    assert {:ok, response} = SimpleHttp.post "http://localhost:4000/", [
      body: "{\"name\":\"foo.example.com\"}",
      content_type: "application/json",
      timeout: 1000,
      connect_timeout: 1000
    ]
    assert response.__struct__ == SimpleHttp.Response
  end
end
