class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    if authenticated?
      @featured_polls = Poll.where(id: [ 1, 2 ])
      @polls = Current.session.user.polls.order(created_at: :desc)
    else
      @polls = nil
    end
  end
end
