class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def instagram
    generic_callback( 'instagram' )
  end

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
    @identity = Identity.find_for_oauth env["omniauth.auth"]

    @user = @identity.user || current_user || User.find_by(email: @identity.email)
    if @user.nil?
      if @identity.email.present?
        @user = User.new( email: @identity.email )
      else
        @user = User.new( email: "temporary.#{@identity.id}@fakemail.com", temporary: true )
      end
      @user.password = Devise.friendly_token[0,20]  # Fake password for validation
      @user.facebook_picture_url = env["omniauth.auth"].info.image
      @user.save
      @identity.update_attribute( :user_id, @user.id )
    end

    if @user.email.blank? && @identity.email
      @user.update_attribute( :email, @identity.email)
    end

    if @user.persisted?
      @identity.update_attribute( :user_id, @user.id )
      @user = FormUser.find @user.id

      set_flash_message(:notice, :success, kind: provider.capitalize) if is_navigational_format?
      sign_in_and_redirect @user, event: :authentication
    else
      # session["devise.#{provider}_data"] = env["omniauth.auth"]
      redirect_to root_path
    end
  end
end


