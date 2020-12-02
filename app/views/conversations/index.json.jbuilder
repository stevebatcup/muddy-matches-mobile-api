if @conversations&.any?
  json.conversations @conversations do |conversation|
    json.converser do
      other_profile = conversation.other_profile(@current_user.profile)
      json.gender other_profile.gender
      json.displayName other_profile.text_display_name
      json.profileId other_profile.id
      json.photo photo_url(other_profile.main_photo, is_thumbnail: true)
    end
    json.lastMessage do
      message = conversation.last_message
      json.text conversation_msg_snippet(message)
      json.sentAt message.human_sent_at
      json.isRead message.read?
      json.isNew !message.read? && current_user.profile.id == message.recipient_profile_id
    end
  end
end

json.error @error if @error
