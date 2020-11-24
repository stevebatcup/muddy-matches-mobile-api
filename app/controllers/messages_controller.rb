class MessagesController < ApplicationController
  include ActionController::Helpers
  helper MessagingHelper

  before_action :authorise_user!

  def show
    @message = Message.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { status: :fail, error: I18n.t('messaging.error.no_message') }, status: 500
  end

  def create
    return render json: { error: I18n.t('messaging.error.no_subscription') }, status: 403 unless current_user.subscriber?
    return render json: { error: I18n.t('profile_not_ready') }, status: 403 unless current_user.profile.visible_and_approved?
    return render json: { status: :fail, error: I18n.t('messaging.error.no_recipient') }, status: 500 if recipient.nil?

    @conversation = Conversation.find_or_build_between(current_user, recipient)
    @conversation.messages << new_message
    @conversation.save
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
