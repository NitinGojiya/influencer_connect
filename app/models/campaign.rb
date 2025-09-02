class Campaign < ApplicationRecord
  belongs_to :user
  belongs_to :city

  # 1. Require content_type
  validates :content_type, presence: true

  # 2 & 3. Custom date validations
  validate :approval_deadline_cannot_be_in_past
  validate :posting_start_date_cannot_be_in_past
  validate :posting_start_date_after_approval_deadline

  private

  def approval_deadline_cannot_be_in_past
    if approval_deadline.present? && approval_deadline < Date.today
      errors.add(:approval_deadline, "can't be in the past")
    end
  end

  def posting_start_date_cannot_be_in_past
    if posting_start_date.present? && posting_start_date < Date.today
      errors.add(:posting_start_date, "can't be in the past")
    end
  end

  def posting_start_date_after_approval_deadline
    if approval_deadline.present? && posting_start_date.present? &&
       posting_start_date < approval_deadline
      errors.add(:posting_start_date, "must be after the approval deadline")
    end
  end
end
