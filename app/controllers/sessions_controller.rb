class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new register create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    @is_new_user = request.path == "/register"
  end

  def register
    begin
      user = User.create(params.permit(:email_address, :password))
      if user
        start_new_session_for user
        redirect_to root_path, notice: "Account created successfully!"
        return
      end
    rescue ActiveRecord::RecordNotUnique
    end

    redirect_to register_path, alert: "Could not register a new account with that email address."
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to login_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to root_path
  end
end
