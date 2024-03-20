defmodule Chatbot.DbDataScheme do
  @enforce_keys [:location, :description, :gender]
  defstruct [:location, :description, :gender]

  def new(location, description, gender) when is_binary(location) and is_binary(description) and is_binary(gender) do
    %__MODULE__{location: location, description: description, gender: gender}
  end
end
