json.error @error if @error

if @new_message
  json.message do
    json.body @new_message.body
  end
end

if @conversation
  json.conversation do
    json.id @conversation.id
  end
end
