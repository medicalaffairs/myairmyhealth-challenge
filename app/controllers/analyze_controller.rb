class AnalyzeController < ApplicationController

  before_filter :authenticate_user!

	def index
		@user = User.find(current_user)
		@devices = @user.devices

		@chart = LazyHighCharts::HighChart.new('graph')
  end

end
