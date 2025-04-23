module OptionsHelper
  def get_vote_percentage(option, poll)
    if poll.vote_count == 0
      return 0
    end
    ((option.vote_count.to_f / poll.vote_count) * 100)
  end
end
