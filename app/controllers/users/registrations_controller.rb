class Users::RegistrationsController < Devise::RegistrationsController

  before_filter :configure_permitted_parameters

  def create
    build_resource(sign_up_params)
    @user.email = params[:user][:email]
    @user.save
    super
    session['omniauth'] = nil unless @user.new_record?
  end


  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:full_name)
    devise_parameter_sanitizer.for(:account_update).push(:full_name)
  end

  private
  def build_resource(*args)
    super
    if session['omniauth']
      @user = User.from_omniauth(session['omniauth'])
      @user.valid?
    end

  end

end
