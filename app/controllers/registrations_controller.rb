class RegistrationsController < Devise::RegistrationsController

	def after_sign_up_path_for(user)
      user_profile_path
    end

	def after_update_path_for(user)
      user_profile_path
    end

end
