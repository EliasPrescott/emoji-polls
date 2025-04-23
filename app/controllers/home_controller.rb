class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    if authenticated?
      @polls = Current.session.user.polls.order(created_at: :desc)
    else
      @polls = nil
    end
  end
end
