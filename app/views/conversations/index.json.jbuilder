if @conversations&.any?
  json.conversations @conversations do |conversation|
    other_profile = conversation.other_profile(@current_user.profile)

    json.gender other_profile.gender
    json.displayName other_profile.text_display_name
    json.lastMessage do
      msg = conversation.last_message
      json.text conversation_msg_snippet(msg)
    end
  end
end

json.error @error if @error
