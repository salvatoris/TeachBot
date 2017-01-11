class ChatControllers::MessagesController < ApplicationController
  include MessagesHelper, MessageStrategies::MessageCreateStrategy,
          MessageStrategies::MessageCreateStrategy::MessageMakers
  before_action :require_user

  def create

    chat = get_from_cache(Chat, params[:chat_id])

    message = current_user.messages.new(message_params)

    strategy = MessageCreate.new(chat, message, current_user)

    unless strategy.have_access_to_chat?
      return error_message('Forbidden', 403)
    end

    if strategy.public_chat?
      save_message(strategy, PublicMessageMaker.new)
    else
      save_message(strategy, PrivateMessageMaker.new) { render :json => {:message => 'Message has been sent'} }
    end
  end

  private

  def message_params
    params.require(:message).permit(:text)
  end

  def save_message(strategy, maker)
    unless strategy.save_as(maker)
      return error_message(maker.errors, 422)
    end
    if block_given?
      yield
    end
  end
end
