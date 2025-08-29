class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  has_one_attached :image

  validates :content, presence: true, unless: -> { image.attached? }

  after_create_commit :broadcast_to_sender_and_receiver

  private

  def broadcast_to_sender_and_receiver
    # reload with attachment preloaded
    message_with_image = Message.with_attached_image.find(id)

    # Broadcast to sender
    broadcast_append_to(
      "messages_#{conversation.id}_#{user.id}",
      target: "messages",
      partial: "messages/message",
      locals: { message: message_with_image, current_user: user }
    )

    # Broadcast to receiver
    receiver = (conversation.sender == user ? conversation.receiver : conversation.sender)
    broadcast_append_to(
      "messages_#{conversation.id}_#{receiver.id}",
      target: "messages",
      partial: "messages/message",
      locals: { message: message_with_image, current_user: receiver }
    )
  end
end
