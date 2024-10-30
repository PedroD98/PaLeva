class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resources)
    if current_user && !current_user.registered_restaurant
      new_restaurant_path
    else
      restaurant_path(current_user.restaurant)
    end
  end

  def user_has_registered_restaurant?
    if !current_user.registered_restaurant
      redirect_to new_restaurant_path, alert: 'Antes de seguir em frente, precisamos que você cadastre seu restaurante.'
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :surname, :social_number, :registred_restaurant])
  end
end