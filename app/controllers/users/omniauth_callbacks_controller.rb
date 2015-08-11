class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    generic_callback( 'facebook' )
  end

  def twitter
    generic_callback( 'twitter' )
  end

  def google_oauth2
    generic_callback( 'google_oauth2' )
  end

  def generic_callback( provider )
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider.capitalize) if is_navigational_format?
    else
      redirect_to new_user_registration_url
    end
  end

  def after_omniauth_failure_path_for(scope)
    root_path(scope)
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || (current_user.sign_in_count == 1 ? first_user_home_path(current_user) : user_home_path(current_user))
  end


end
