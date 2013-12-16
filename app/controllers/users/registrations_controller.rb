class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  before_filter :admin_user,     only: [:destroy, :index]

  def index
    @users = User.order("email")
  end

  def create
    super
    puts "---------- create user from RegistrationsController ---------"
  end

  def update
    super
    puts "---------- update user from RegistrationsController ---------"
  end

  private
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
