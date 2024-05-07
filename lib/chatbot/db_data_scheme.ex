defmodule Chatbot.DbDataScheme do
  @enforce_keys [:birth_location, :age, :gender, :ca,  :description]
  defstruct [:birth_location, :age, :gender, :ca,  :description, :review]

  def new(birth_location, age, gender, ca, description, review) when is_binary(birth_location) and is_binary(description) and is_binary(gender) do
    %__MODULE__{birth_location: birth_location, age: age, gender: gender, ca: ca, description: description, review: review}
  end
end
