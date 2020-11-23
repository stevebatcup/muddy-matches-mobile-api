if @message
  json.message do
    json.body @message.body
  end
end
