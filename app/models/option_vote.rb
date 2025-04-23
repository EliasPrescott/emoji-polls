class OptionVote < ApplicationRecord
  belongs_to :option
  belongs_to :poll
  belongs_to :user
end
