class MessagesController < ApplicationController
  before_action :authorise_user!

  def show
    @message = Message.find(params[:id])
  end

  def create
    return raise ActiveRecord::RecordNotFound if recipient.nil?

    conversation = Conversation.find_or_build_between(current_user, recipient)
    conversation.messages << new_message

    if conversation.save
      @message = new_message
      @conversation = conversation
    else
      @error = 'foo'
    end
  end

  private

  def recipient
    @recipient ||= User.find_by(profile_id: params[:recipient_profile_id])
  end

  def new_message
    @new_message ||= Message.new({
                                   sender_profile_id:    current_user.profile.id,
                                   recipient_profile_id: recipient.profile.id,
                                   body:                 params[:body]
                                 })
  end
end
