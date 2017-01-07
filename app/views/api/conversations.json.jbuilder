json.array! @chats do |chat|
  json.extract! chat, :id
  json.users chat.users, :id, :username, :avatar
  json.unread_messages_count current_user.unread_messages.where(:messages => {chat_id: chat.id}).count

  if (last_msg = chat.messages.last)
    json.last_message do
      json.extract! last_msg, :id, :text, :created_at
      json.user last_msg.user, :id, :username, :avatar
      json.read check_if_read(last_msg)
    end
  end
end
