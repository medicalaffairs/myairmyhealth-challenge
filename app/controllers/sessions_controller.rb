class SessionsController < Devise::SessionsController 

	def new
		@title = "Sign in" 
	end

	def after_sign_in_path_for(user)
      analyze_path
    end
end
