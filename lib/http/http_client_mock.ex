defmodule Http.HttpClientMock do
  alias Http.HttpBehaviour
  @behaviour HttpBehaviour

  def post(_, nil, _) do
  end

  def post(_, body, _) do
    case body.age do
      20 -> {:ok, %HTTPoison.Response{status_code: 201}}
      25 -> {:error, %HTTPoison.Error{}}
    end
  end

end
