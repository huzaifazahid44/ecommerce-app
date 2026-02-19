class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = "user" # Default role for new signups
    
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Account created successfully! Welcome!"
      redirect_to root_path
    else
      flash.now[:error] = "Please fix the errors below"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
