class Conversation < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  # Scope to order conversations by latest message
  scope :order_by_last_message, -> {
    left_joins(:messages)
      .group(:id)
      .order(Arel.sql("MAX(messages.created_at) DESC NULLS LAST"))
  }

  # Get the last message of the conversation
  def last_message
    messages.order(created_at: :desc).first
  end

  # Get the other participant in the conversation
  def other_user(current_user)
    sender == current_user ? receiver : sender
  end
end
