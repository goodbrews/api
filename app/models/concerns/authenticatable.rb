module Authenticatable
  extend ActiveSupport::Concern

  included do
    has_secure_password
    attr_accessor :current_password

    validates :password, length: {
                         minimum: 8,
                         maximum: 50,
                         message: 'must be between 8 and 50 characters',
                         allow_blank: true
                       }
  end

  def update_with_password(params, *options)
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if authenticate(current_password)
      update_attributes(params, *options)
    else
      self.assign_attributes(params, *options)
      self.valid?
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end

    self.password = self.password_confirmation = nil
    result
  end
end
