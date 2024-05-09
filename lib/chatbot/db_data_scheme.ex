defmodule Chatbot.DbDataScheme do

  defstruct [:birth_location, :age, :gender, :ca,  :description, :review]

  def new(birth_location, age, gender, ca, description, review) do
    %__MODULE__{birth_location: birth_location, age: age, gender: gender, ca: ca, description: description, review: review}
  end
end
