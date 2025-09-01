class DeleteUnconfirmedUsersJob < ApplicationJob
  queue_as :default

  def perform
    User.unconfirmed_for(30.minutes).find_each do |user|
      user.destroy
      Rails.logger.info "Deleted unconfirmed user: #{user.email_address}"
    end
  end
end
