if @message
  json.message do
    json.body msg_content(@message)
  end
end
