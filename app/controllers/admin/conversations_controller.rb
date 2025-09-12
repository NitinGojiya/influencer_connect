module Admin
  class ConversationsController < Admin::ApplicationController
    def find_resource(param)
      Conversation.friendly.find(param)
    end
  end
end
