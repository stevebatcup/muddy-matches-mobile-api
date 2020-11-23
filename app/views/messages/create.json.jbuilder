json.error @error if @error

if @message
  json.message do
    json.body @message.body
  end
end

if @conversation
  json.conversation do
    json.id @conversation.id
  end
end
