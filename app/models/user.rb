class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :omniauthable,
         :omniauth_providers => [:facebook, :google_oauth2, :twitter]

  validates :email, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i  }

  def confirmation_required?
    super && email.present?
  end

  def password_required?
    super && provider.blank?
  end

  def self.from_omniauth(auth)
    user = User.find_by_provider_and_uid(auth.provider, auth.uid)
    if user.blank?
      user = User.new
      user.email = auth.info.email if auth.info.email
      user.full_name = auth.info.name
      user.image = auth.info.image
      user.provider = auth.provider
      user.uid = auth.uid
      user.password = Devise.friendly_token[0,20]
      user.skip_confirmation!
    end

    unless user.image == auth.info.image
      user.image = auth.info.image
    end
    user
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def profile_photo
    if provider == 'facebook'
      image + '?type=normal'
    else
      image
    end
  end
end
