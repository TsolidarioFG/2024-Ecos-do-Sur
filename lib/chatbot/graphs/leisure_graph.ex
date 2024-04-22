defmodule Chatbot.LeisureGraph do
  alias Chatbot.TelegramWrapper, as: TelegramWrapper
  alias Chatbot.HistoryFormatting

  @doc """
  This module represents the Leisure Graph of the bot. It handles the behaviour of it till it reaches a solution
  or it enters another graph.
  """

  ##################################
  # START
  ##################################
  # 1 -----
  def resolve({:start, _, _}, user, key, _, message_id) do
    keyboard = [[%{text: "NIEGAN ENTRADA", callback_data: "ENTRANCE"}, %{text: "CAMBIAN PRECIO", callback_data: "PRICE"}]]
    history = [{:start, :leisure}]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage("Qué está sucediendo?", history), user, message_id, key)
    {{:start_final_resolve, :leisure}, history, nil}
  end

  def resolve({:start_final_resolve, history, _}, user, key, "ENTRANCE", message_id), do: resolve({:S1, history, nil}, user, key, nil, message_id)
  def resolve({:start_final_resolve, history, _}, user, key, "PRICE", message_id), do: resolve({:S2, history, nil}, user, key, nil, message_id)

  ##################################
  # ENTRANCE
  ##################################
  # 2 -----
  def resolve({:EN, history, _}, user, key, _, _) do
    keyboard = [[%{text: "SI", callback_data: "YES"}, %{text: "NO", callback_data: "NO"}]]
    new_history = [{:EN, :leisure} | history]
    TelegramWrapper.send_menu(keyboard, HistoryFormatting.buildMessage("Te han entregado la hoja de reclamaciones?", new_history), user, key)
    {{:EN_resolve, :leisure}, new_history, nil}
  end

  def resolve({:EN_resolve, history, _}, user, key, "YES", message_id), do: resolve({:EN_1, history, nil}, user, key, nil, message_id)
  def resolve({:EN_resolve, history, _}, user, key, "NO", message_id), do: resolve({:S3, history, nil}, user, key, nil, message_id)
  # 3 -----
  def resolve({:EN_1, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: "SI", callback_data: "YES"}, %{text: "NO", callback_data: "NO"}]]
    new_history = [{:EN_1, :leisure} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage("Necesitas ayuda para cubrirla?", new_history), user, message_id, key)
    {{:EN_1_resolve, :leisure}, new_history, nil}
  end

  def resolve({:EN_1_resolve, history, _}, user, key, "YES", message_id), do: resolve({:S4, history, nil}, user, key, nil, message_id)
  def resolve({:EN_1_resolve, history, _}, user, key, "NO", message_id), do: resolve({:EN_2_1, history, nil}, user, key, nil, message_id)
  # 4 -----
  def resolve({:EN_2, history, _}, user, key, _, _) do
    keyboard = [[%{text: "SI", callback_data: "YES"}, %{text: "NO", callback_data: "NO"}]]
    new_history = [{:EN_2, :leisure} | history]
    TelegramWrapper.send_menu(keyboard, HistoryFormatting.buildMessage("Quieres más información?", new_history), user, key)
    {{:EN_2_resolve, :leisure}, new_history, nil}
  end

  def resolve({:EN_2_1, history, _}, user, key, _, message_id) do
    keyboard = [[%{text: "SI", callback_data: "YES"}, %{text: "NO", callback_data: "NO"}]]
    new_history = [{:EN_2, :leisure} | history]
    TelegramWrapper.update_menu(keyboard, HistoryFormatting.buildMessage("Quieres más información?", new_history), user, message_id, key)
    {{:EN_2_resolve, :leisure}, new_history, nil}
  end

  def resolve({:EN_2_resolve, history, _}, user, key, "YES", message_id), do: resolve({:S5, history, nil}, user, key, nil, message_id)
  def resolve({:EN_2_resolve, history, _}, user, key, "NO", message_id), do: resolve({:S6_1, history, nil}, user, key, nil, message_id)

  ##################################
  # SOLUTIONS
  ##################################
  # S1-Q2 -
  def resolve({:S1, history, _}, user, key, _, message_id) do
    TelegramWrapper.update_menu(
      [],
      "Si te impiden la entrada a un establecimiento, es clave solicitar siempre el LIBRO DE RECLAMACIONES a la persona que esté en el local (portero, camarero, dependiente, etc.), aunque no hayas llegado a entrar ni ser cliente.
La hoja de reclamaciones constituye una prueba en el caso de llegar a reclamar mediante arbitraje de consumo o demanda judicial, por eso es muy importante que lo solicites cuanto antes de forma educada.",
      user,
      message_id,
      key
    )
    resolve({:EN, history, nil}, user, key, nil, message_id)
  end

  # S2 ----
  def resolve({:S2, history, _}, user, key, _, message_id) do
    TelegramWrapper.update_menu(
      [],
      "El precio de la entrada debe ser el estipulado en la web del lugar o en sus medios. Si este precio cambia al llegar al lugar del pago, puede que estés siendo estafado. (RELLENAR)",
      user,
      message_id,
      key
    )
    resolve({:S6, history, nil}, user, key, nil, message_id)
  end
  # S3 ----
  def resolve({:S3, _, _}, user, key, _, message_id) do
    TelegramWrapper.update_menu(
      [],
      "Si se niegan a dártelo, llama a la Policía Local (092) que será la encargada de tramitar la denuncia por la negativa a entregarlo o no disponer de este. En caso de que estuvieras en estado de irregularidad, no te preocupes, en España tienes derecho a este tipo de asistencia y no pueden deportarte ni pedirte tu documentación de migrante regulado.",
      user,
      message_id,
      key
    )
    {:solved, nil, nil}
  end
  # S4-Q4 -
  def resolve({:S4, history, _}, user, key, _, message_id) do
    TelegramWrapper.update_menu(
      [],
      "Todos los establecimientos abiertos al público deben disponer de hojas de reclamación compuestas de tres copias (una para ellos, otra para ti y otra para la administración).
No la tienes por qué rellenar en ese momento, te la puedes llevar y hacerlo con calma.
Los campos que hay que rellenar para que la hoja de reclamaciones esté completa son fundamentalmente:
1. Los datos de la persona reclamante. Nombre, apellidos, DNI, domicilio y teléfono de contacto
¡Hola! 👋 Soy un asistente virtual de Ecos do Sur que te va a echar una mano cuando
sufras o seas testigo de discriminación por motivos de racismo, xenofobia o religión.
2. Los datos de la empresa o profesional a quien se reclama. Nombre comercial, denominación social, domicilio, NIF y teléfono de la empresa.
3. La descripción completa del hecho, incluyendo fecha y lugar. Es importante explicar de manera concisa qué sucedió y escribir en mayúsculas. Puedes añadir un escrito aparte si no tienes suficiente espacio.
4. Lo que se solicita: compensación, disculpa, etc.
5. Documentos adjuntos. Si tienes fotos, estas servirán de base a la reclamación.
6. Lleva la hoja a Consumo. Lo primero que debes hacer con la hoja de reclamaciones es dársela al reclamado y esperar su respuesta durante diez días.
Después de eso, si no tienes respuesta, tienes que presentarla de manera presencial o telemática en la OMIC correspondiente o en la Dirección General de Consumo de tu Comunidad.
Puedes llevar este material a una ONGs especializada como Ecos do Sur.
También puedes llamar al Consejo para la Eliminación de la Discriminación Racial o Étnica
(CEDRE) en el 021, escribirles al WhatsApp: 628 860 507 o al correo: consejo-sei@igualdad.gob.es",
      user,
      message_id,
      key
    )
    resolve({:EN_2, history, nil}, user, key, nil, message_id)

  end
  # S5 ----
  def resolve({:S5, _, _}, user, key, _, message_id) do
    TelegramWrapper.update_menu(
      [],
      "¿Sabías qué? El derecho de admisión, que es el derecho que tienen los propietarios de establecimientos para decidir quién puede entrar y quién no, no puede ser aplicado de manera arbitraria ni discriminatoria. Los carteles que indican \"Reservado el Derecho de Admisión\" no justifican políticas de admisión que discriminan a las personas por su raza, color de piel, religión, género u otras características protegidas por la ley. La discriminación en el acceso a establecimientos públicos está prohibida en muchos países y puede acarrear consecuencias legales para los propietarios que la practiquen. Es importante que los establecimientos respeten los derechos de todas las personas y no incurran en prácticas discriminatorias.",
      user,
      message_id,
      key
    )
    resolve({:S6, nil, nil}, user, key, nil, message_id)
  end
  # S6 ----
  def resolve({:S6, _, _}, user, key, _, _) do
    TelegramWrapper.send_menu(
      [],
      "Sufrir discriminación es duro emocionalmente, por lo que no dudes en buscar apoyo en amigos, familiares u organizaciones, como Ecos do Sur, especializadas en ayudar a personas que han tenido las mismas experiencias. No estás sola.",
      user,
      key
    )
    {:solved, nil, nil}
  end

  def resolve({:S6_1, _, _}, user, key, _, message_id) do
    TelegramWrapper.update_menu(
      [],
      "Sufrir discriminación es duro emocionalmente, por lo que no dudes en buscar apoyo en amigos, familiares u organizaciones, como Ecos do Sur, especializadas en ayudar a personas que han tenido las mismas experiencias. No estás sola.",
      user,
      message_id,
      key
    )
    {:solved, nil, nil}
  end
end
