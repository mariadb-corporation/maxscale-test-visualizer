# Controller for OAuth authorization
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    setup_user_and_sign_in
  end

  def after_omniauth_failure_path_for(_scope)
    return_path
  end

  private

  def setup_user_and_sign_in
    @user = User.from_omniauth(request.env['omniauth.auth'])
    sign_in_and_redirect @user
  end

  def return_path
    session.delete(:guest_return_url) || user_session_path
  end
end
