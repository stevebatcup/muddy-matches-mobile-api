class ConversationsController < ApplicationController
  include ActionController::Helpers
  helper MessagingHelper
  helper ProfileHelper

  before_action :authorise_user!

  def index
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 1).to_i
    @conversations = Conversation.list_for_user(current_user, page, per_page)
  end

  def show
    @conversation = Conversation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { status: :fail, error: I18n.t('messaging.error.no_conversation') }, status: 500
  end
end
