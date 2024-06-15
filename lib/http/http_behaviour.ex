defmodule Http.HttpBehaviour do
  @type headers ::
  [{atom(), binary()}]
  | [{binary(), binary()}]
  | %{required(binary()) => binary()}
  | any()

  @type body :: Chatbot.DbDataScheme.t() | nil

  @callback post(url :: binary(), body :: body(), header :: headers()) ::
  {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t() | HTTPoison.MaybeRedirect.t()}
  | {:error, HTTPoison.Error.t()}
end
