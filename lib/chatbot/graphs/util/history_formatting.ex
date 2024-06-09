defmodule Chatbot.HistoryFormatting do
  import ChatBot.Gettext
  def buildMessage(message, nil), do: "*" <> message <> "*"
  def buildMessage(message, history) do
    string_list =
      Enum.map(history, &state_to_string/1)
      |> Enum.filter(&(&1 != nil))
      |> Enum.map(&("✅ " <> &1))
      |> Enum.reverse()

    Enum.join(string_list, "\n") <> "\n\n" <> "*" <> message <> "*"
  end

  defp state_to_string(state) do
    case state do
      # INITIAL STATES  -----
      {:U1_new, :initial} -> gettext("URGENT")
      {:U2, :initial} -> gettext("NO DANGER")
      # LEISURE STATES  -----
      {:start, :leisure} -> gettext("LEISURE")
      # HOSPITAL STATES -----
      {:start, :hospital} -> gettext("HOSPITAL")
      {:U1, :hospital} -> gettext("HOSPITAL SERVICE DENIAL")
      # HOME STATES     -----
      {:start, :home} -> gettext("HOME")
      {:Q2, :home} -> gettext("TENANT")
      {:Q3, :home}  -> gettext("LANDLORD")
      {:Q3_1, :home}  -> gettext("WANT TO RENT")
      # PER-WORK STATES -----
      {:start, :work_per} -> gettext("PERSON AT WORK")
      # SCHOOL STATES   -----
      {:start, :school} -> gettext("SCHOOL")
      {:TE_Q7, :school} -> gettext("TEACHER")
      {:TE, :school} -> gettext("STUDENT")
      {:AC, :school} -> gettext("ACTIVITIES")
      {:AC_SEC, :school} -> gettext("SECRETARY")
      {:AC_EX, :school} -> gettext("EXTRACURRICULAR")
      {:AC_CA, :school} -> gettext("CANTEEN")
      # COMMERCE STATES -----
      {:start, :commerce} -> gettext("COMMERCE")
      # WORK STATES     -----
      {:start, :work} -> gettext("WORK")
      {:EM, :work} -> gettext("EMPLOYEE")
      {:Q3, :work} -> gettext("JOB CANDIDATE")
      {:Q3_1, :work} -> gettext("WORKER")
      {:Q3_2, :work} -> gettext("BOSS")
      _ -> nil
    end
  end
end
