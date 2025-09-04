class Message < ApplicationRecord
  include ActionView::RecordIdentifier
  belongs_to :conversation
  belongs_to :user

  has_one_attached :image

  validates :content, presence: true, unless: -> { image.attached? }

  after_create_commit :broadcast_to_sender_and_receiver, :broadcast_to_notification


  private

  def broadcast_to_notification
  message_with_image = Message.with_attached_image.find(id)
  receiver = conversation.sender == user ? conversation.receiver : conversation.sender

  # only receiver gets a notification
  broadcast_prepend_to(
    receiver,
    target: "notifications",
    partial: "messages/notification",
    locals: { message: message_with_image }
  )
end

  def broadcast_to_sender_and_receiver
    # reload with attachment preloaded
    message_with_image = Message.with_attached_image.find(id)

    # --- 1) Broadcast message to chat window ---
    broadcast_to_chat(message_with_image)

    # --- 2) Broadcast update to conversations list ---
    broadcast_to_conversation_list
  end

  def broadcast_to_chat(message_with_image)
    # To sender
    broadcast_append_to(
      "messages_#{conversation.id}_#{user.id}",
      target: "messages",
      partial: "messages/message",
      locals: { message: message_with_image, current_user: user }
    )

    # To receiver
    receiver = conversation.sender == user ? conversation.receiver : conversation.sender
    broadcast_append_to(
      "messages_#{conversation.id}_#{receiver.id}",
      target: "messages",
      partial: "messages/message",
      locals: { message: message_with_image, current_user: receiver }
    )
  end

  def broadcast_to_conversation_list
    [conversation.sender, conversation.receiver].each do |participant|
      # Replace row (update last message text)
      broadcast_replace_to(
        participant,
        target: dom_id(conversation),
        partial: "conversations/list",
        locals: { conversation: conversation, user: participant }
      )

      # (Optional) Move conversation to top of list
      broadcast_remove_to participant, target: dom_id(conversation)
      broadcast_prepend_to(
        participant,
        target: "conversations",
        partial: "conversations/list",
        locals: { conversation: conversation, user: participant }
      )
    end
  end
end
