class MessagesController < ApplicationController
  before_action :set_conversation
  before_action :set_user

  def create
    @message = @conversation.messages.new(message_params.merge(user: current_user))
    if @message.save
      head :ok # ✅ no extra reload, the model handles broadcasting
    else
      # render errors if needed
    end
  end

  private

  def set_conversation
    @conversation = Conversation.friendly.find(params[:conversation_id])
  end

  def set_user
    @user = Current.session.user
  end

  def message_params
    params.require(:message).permit(:content, :image)
  end
end
