# app/helpers/messages_helper.rb
module MessagesHelper
  def message_user_alignment(message, current_user)
    message.user == current_user ? 'text-right' : 'text-left'
  end

  def message_user_style(message, current_user)
    message.user == current_user ? 'bg-blue-500 text-white' : 'bg-gray-700 text-gray-200'
  end
end