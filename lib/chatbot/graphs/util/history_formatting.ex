defmodule Chatbot.HistoryFormatting do

  def buildMessage(message, nil), do: "*" <> message <> "*"
  def buildMessage(message, history) do
    string_list =
    Enum.map(history, fn state -> "✅ " <> state_to_string(state) end)
    |> Enum.reverse()

    Enum.join(string_list, "\n") <> "\n\n" <> "*" <> message <> "*"
  end

  defp state_to_string(state) do
    case state do
      {:start, :initial} -> "START"
      {:U1 , :initial} -> "Urgente"
      {:U1_1, :initial} -> "Yo"
      {:U1_2, :initial} -> "Otro"
      {:I1, :initial} -> "Información"
      {:U2, :initial} -> "Sin peligro"
      {:U2_1, :initial} -> "Lugar definido"
      {:U2_3, :initial} -> "Con el personal del establecimiento"
      {:U2_4, :initial} -> "Con otra persona."
      {:start, :leisure} -> "Ocio"
      {:EN, :leisure} -> "Niegan Entrada"
      {:EN_1, :leisure} -> "Con hoja de reclamaciones"
      {:EN_2, :leisure} -> "Necesito ayuda para rellenarla"
      _ -> "Not Implemented Yet"
    end
  end
end
