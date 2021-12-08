defmodule Persona do
  @moduledoc """
  This library provides an Elixir API for accessing the [Persona APIs](https://docs.withpersona.com/reference/introduction).

  The API access uses the [Tesla](https://github.com/teamon/tesla) library and
  relies on the caller passing in an an API Key to create a
  client. The client is then passed into all API calls.

  The API returns a 3 element tuple. If the API HTTP status code is less
  the 300 (ie. suceeded) it returns `:ok`, the HTTP body as a map and the full
  Tesla Env if you need to access more data about thre return. if the API HTTP
  status code is greater than 300. it returns `:error`, the HTTP body and the
  Telsa Env. If the API doesn't return at all it should return `:error`, a blank
  map and the error from Tesla.

  ## Installation

  If [available in Hex](https://hex.pm/docs/publish), the package can be
  installed by adding `persona_api` to your list of dependencies in `mix.exs`:

      def deps do
        [
          {:persona_api, "~> 0.0.1"},
        ]
      end

  Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
  and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
  be found at [https://hexdocs.pm/persona_api](https://hexdocs.pm/persona_api).
  """
  @type client() :: Tesla.Client.t()
  @type result() :: {:ok, map() | String.t(), Tesla.Env.t()} | {:error, map(), any}

  @spec client(String.t()) :: client()
  def client(api_key, api_version \\ nil) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://withpersona.com/api/v1"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, headers(api_key, api_version)}
    ]

    Tesla.client(middleware, adapter())
  end

  defp headers(api_key, nil), do: [{"Authorization", "Bearer " <> api_key}]

  defp headers(api_key, api_version),
    do: headers(api_key, nil) ++ [{"Persona-Version", api_version}]

  @spec result({:ok, Tesla.Env.t()}) :: result()
  def result({:ok, %{status: status, body: body} = env}) when status < 300 do
    {:ok, body, env}
  end

  @spec result({:ok, Tesla.Env.t()}) :: result()
  def result({:ok, %{status: status, body: body} = env}) when status >= 300 do
    {:error, body, env}
  end

  @spec result({:error, any}) :: result()
  def result({:error, any}), do: {:error, %{}, any}

  @doc false
  def adapter do
    case Application.get_env(:persona_api, :tesla) do
      nil -> {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}
      tesla -> tesla[:adapter]
    end
  end
end
