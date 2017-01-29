class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  include CustomHelper::Responses
  include CustomHelper::Cache
  helper_method :current_user, :it_is_current_user

  # if no session[:user_id] - check cookie and log_in user with its value (id of the user)
  # @return [User]
  def current_user
    if (user_id = session[:user_id])
      set_live_id(session[:user_id])
      @current_user ||= get_from_cache(User, user_id) # User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = get_from_cache(User, user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        set_live_id(user.id)
        log_in user
        @current_user = user
      end
    end
  end

  def require_user
    unless current_user
      respond_to do |format|
        format.any(:js, :json) { error_message('You need login to go there', 403) }
        format.html do
          flash[:danger_notice] = 'You need login to go there'
          redirect_to root_url
        end
      end

    end
  end

  def require_guest
    if current_user
      flash[:danger_notice] = 'Access denied for authorized user'
      redirect_to root_url
    end
  end

  def profile_owner
    unless current_user.id === params[:id].to_i
      deny_access_message
    end
  end

  def it_is_current_user(user)
    if current_user && user
      return current_user.id == user.id
    end
    false
  end

  def is_owner?(target, key = 'author_id')
    unless current_user.id === target.send(key)
      return false
    end
    true
  end

  def have_access_to_private_course(course)
    unless course.public
      unless current_user
        flash[:danger_notice] = 'You need login to go there'
        return redirect_to root_path
      end
      unless course.subscribers.find_by_id(current_user.id).present?
        return false
      end
      true
    end
    true
  end

  def require_teacher
    unless @current_user.has_role? :teacher
      flash[:danger_notice] = 'You are not a teacher'
      redirect_to root_path
    end
  end

  # @param [Course] course
  def unpublished_and_user_is_author(course)
    unless course.published
      unless current_user == course.author
        return false
      end
    end
    true
  end


  protected

  def deny_access_message(msg = 'Access denied')
    respond_to do |format|
      format.js { error_message([msg], 403) }
      format.json { error_message([msg], 403) }
      format.html do
        flash[:danger_notice] = msg
        redirect_to root_url
      end
    end
  end

  private
  def set_live_id(id)
    cookies.signed[:live_user_id] = id unless cookies[:live_user_id]
  end
end
