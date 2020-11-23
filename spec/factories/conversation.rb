FactoryBot.define do
  factory :conversation do
    profile_id_1 { 1 }
    profile_id_2 { 2 }
    message_count { 5 }
    last_message_id { 1 }
    created { 6.months.ago }
    modified { 6.months.ago }
    last_message_is_question { false }
    whos_turn { 2 }
  end
end
