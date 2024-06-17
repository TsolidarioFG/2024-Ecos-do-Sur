defmodule ManagerTest do
  use ExUnit.Case
  doctest Chatbot.Manager

  test "init graph initial" do
    new_state = Chatbot.Manager.resolve({{:start, :initial}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :initial}, [{:start, :initial}], nil}
  end

  test "init graph leisure" do
    new_state = Chatbot.Manager.resolve({{:start, :leisure}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :leisure}, [{:start, :leisure}], nil}
  end

  test "init graph school" do
    new_state = Chatbot.Manager.resolve({{:start, :school}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :school}, [{:start, :school}], nil}
  end

  test "init graph hospital" do
    new_state = Chatbot.Manager.resolve({{:start, :hospital}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :hospital}, [{:start, :hospital}], nil}
  end

  test "init graph transport" do
    new_state = Chatbot.Manager.resolve({{:start, :transport}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :transport}, [{:start, :transport}], nil}
  end

  test "init graph commerce" do
    new_state = Chatbot.Manager.resolve({{:start, :commerce}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :commerce}, [{:start, :commerce}], nil}
  end

  test "init graph work" do
    new_state = Chatbot.Manager.resolve({{:start, :work}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :work}, [{:start, :work}], nil}
  end

  test "init graph home" do
    new_state = Chatbot.Manager.resolve({{:start, :home}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :home}, [{:start, :home}], nil}
  end

  test "init graph work_per" do
    new_state = Chatbot.Manager.resolve({{:start, :work_per}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :work_per}, [{:start, :work_per}], nil}
  end

  test "init graph faq" do
    new_state = Chatbot.Manager.resolve({{:start, :faq}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :faq}, [{:start, :faq}], nil}
  end

  test "init graph faq_healthcare" do
    new_state = Chatbot.Manager.resolve({{:start, :faq_healthcare}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :faq_healthcare}, [{:start, :faq_healthcare}], nil}
  end

  test "init graph faq_ca_resources" do
    new_state = Chatbot.Manager.resolve({{:start, :faq_ca_resources}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :faq_ca_resources}, [{:start, :faq_ca_resources}], nil}
  end

  test "init graph faq_commerce" do
    new_state = Chatbot.Manager.resolve({{:start, :faq_commerce}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :faq_commerce}, [{:start, :faq_commerce}], nil}
  end

  test "init graph faq_work" do
    new_state = Chatbot.Manager.resolve({{:start, :faq_work}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :faq_work}, [{:start, :faq_work}], nil}
  end

  test "init graph faq_rent" do
    new_state = Chatbot.Manager.resolve({{:start, :faq_rent}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {{:start_final_resolve, :faq_rent}, [{:start, :faq_rent}], nil}
  end

  test "init graph person" do
    new_state = Chatbot.Manager.resolve({{:S1, :person}, [], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), nil, 1)
    assert new_state == {:solved, nil, nil}
  end

  test "back" do
    new_state = Chatbot.Manager.resolve({{:U1_new_resolve, :initial}, [{:U1_new, :initial}, {:start, :initial}], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), "BACK", 1)
    assert new_state == {{:start_final_resolve, :initial}, [{:start, :initial}], nil}
  end

  test "continue" do
    new_state = Chatbot.Manager.resolve({{:U1_new_resolve, :initial}, [{:U1_new, :initial}, {:start, :initial}], nil}, 1, System.get_env("TELEGRAM_BOT_SECRET"), "CONTINUE", 1)
    assert new_state == {{:U1_new_resolve, :initial}, [{:U1_new, :initial}, {:start, :initial}], nil}
  end
end
