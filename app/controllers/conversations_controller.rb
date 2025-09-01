class ConversationsController < ApplicationController
  layout :choose_layout
  def index
    @user = Current.session.user
    @conversations = Conversation
      .includes(:messages, :sender, :receiver)
      .where("sender_id = :user_id OR receiver_id = :user_id", user_id: @user.id).order_by_last_message
  end

  def show
    @user = Current.session.user
    @conversation = Conversation.find(params[:id])
    @messages = @conversation.messages.includes(:user)
    @message = Message.new
  end

  def new
    @user = Current.session.user
    @conversation = Conversation.new
    @users = User.where.not(id: @user.id) # list all except yourself
  end

  def create
    @user = Current.session.user
    @conversation = Conversation.find_by(sender_id: @user.id, receiver_id: params[:conversation][:receiver_id]) ||
                    Conversation.find_by(sender_id: params[:conversation][:receiver_id], receiver_id: @user.id)

    unless @conversation
      @conversation = Conversation.create(
        sender_id: @user.id,
        receiver_id: params[:conversation][:receiver_id]
      )
    end

    redirect_to @conversation
  end
  private
   def choose_layout
    if current_user&.has_role?(:business_owner)
      "application"
    elsif current_user&.has_role?(:influencer)
      "influencer"
    else
      "application"
    end
  end
end
