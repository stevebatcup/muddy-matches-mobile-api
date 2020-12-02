json.messages @conversation.messages.order(sent: :desc) do |message|
  json.body message.body
  json.sentAt message.human_sent_at
  json.isRead message.read?
  json.isNew message.read? && current_user.profile.id == message.recipient_profile_id

  json.recipient do
    json.displayName message.receiving_profile.text_display_name
    json.profileId message.receiving_profile.id
    json.gender message.receiving_profile.gender
    json.photo photo_url(message.receiving_profile.main_photo, is_thumbnail: true)
  end

  json.sender do
    json.displayName message.sending_profile.text_display_name
    json.profileId message.sending_profile.id
    json.gender message.sending_profile.gender
    json.photo photo_url(message.sending_profile.main_photo, is_thumbnail: true)
  end
end
