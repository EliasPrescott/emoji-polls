module PollDetails
  extend ActiveSupport::Concern

  included do
    helper_method :load_show_details
  end

  def load_show_details(poll_id)
    @poll = Poll
      .where(id: poll_id)
      .left_joins(:option_votes)
      .select("polls.*, COUNT(option_votes.id) AS vote_count")
      .first!

    first_vote_query = OptionVote
      .where(poll_id: poll_id, user_id: Current.session.user.id)
      .limit(1)
    @options = Option
      .joins("LEFT JOIN (#{first_vote_query.to_sql}) user_vote ON user_vote.option_id = options.id")
      .left_joins(:option_votes)
      .where(poll_id: poll_id)
      .select("options.*, user_vote.id AS user_vote_id, COUNT(option_votes.id) AS vote_count")
      .group("options.id")
  end
end
