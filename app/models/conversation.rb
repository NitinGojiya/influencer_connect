class Conversation < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  has_many :messages, dependent: :destroy
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  scope :order_by_last_message, -> {
    left_joins(:messages)
      .group(:id)
      .order(Arel.sql("MAX(messages.created_at) DESC NULLS LAST"))
  }

  def slug_candidates
    [
      ["chat#{rand(100000..999999)}"],          # chat + 6-digit random
      ["chat#{rand(100000..999999)}"],          # fallback if first exists
      ["chat#{SecureRandom.random_number(1_000_000)}"] # final fallback
    ]
  end



  def last_message
    messages.order(created_at: :desc).first
  end

  def other_user(current_user)
    sender == current_user ? receiver : sender
  end

  private

  def parameterize_email(email)
    email.split("@").first.parameterize # take only before @, make it URL-safe
  end
end
