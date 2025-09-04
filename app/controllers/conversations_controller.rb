class ConversationsController < ApplicationController
  layout :choose_layout

  before_action :set_user
  before_action :set_conversation, only: [:show]
  before_action :authorize_conversation!, only: [:show]

  def index
    @conversations = Conversation
      .includes(:messages, :sender, :receiver)
      .where("sender_id = :user_id OR receiver_id = :user_id", user_id: @user.id)
      .order_by_last_message

    # If `open_conversation_id` param exists, preload that conversation
    if params[:open_conversation_id]
      @conversation = Conversation.friendly.find(params[:open_conversation_id])
      if authorized_conversation?(@conversation)
        @messages = @conversation.messages.includes(:user)
        @message = Message.new
      else
        redirect_to conversations_path, alert: "You are not authorized to view that conversation."
      end
    end
  end

  def show
    @messages = @conversation.messages.includes(:user)
    @message = Message.new

    # Get the "other user" in the conversation
    other_user = (@conversation.sender == @user ? @conversation.receiver : @conversation.sender)

    # Mark all messages **sent by the other user** as seen
    @conversation.messages.where(user: other_user, seen: false).find_each do |message|
      message.update(seen: true)
    end
  end

  def new
    @conversation = Conversation.new
    @users = User.where.not(id: @user.id) # list all except yourself
  end

  def create
    @conversation = Conversation.find_by(sender_id: @user.id, receiver_id: params[:conversation][:receiver_id]) ||
                    Conversation.find_by(sender_id: params[:conversation][:receiver_id], receiver_id: @user.id)

    unless @conversation
      @conversation = Conversation.create(
        sender_id: @user.id,
        receiver_id: params[:conversation][:receiver_id]
      )
    end

    # Always redirect to index with the conversation pre-selected using slug
    redirect_to conversations_path(open_conversation_id: @conversation.slug)
  end

  private

  def set_user
    @user = Current.session.user
  end

  def set_conversation
    @conversation = Conversation.friendly.find(params[:id])
  end

  # Ensure current user is either sender or receiver
  def authorize_conversation!
    unless authorized_conversation?(@conversation)
      redirect_to conversations_path, alert: "You are not authorized to view that conversation."
    end
  end

  def authorized_conversation?(conversation)
    conversation.sender_id == @user.id || conversation.receiver_id == @user.id
  end

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
