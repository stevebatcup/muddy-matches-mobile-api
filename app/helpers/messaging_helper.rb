module MessagingHelper
  def msg_content(msg)
    if current_user.subscriber? || msg.read?
      msg.body
    else
      I18n.t('messaging.message_locked')
    end
  end

  def conversation_msg_snippet(msg)
    msg_content(msg).truncate(50)
  end
end
