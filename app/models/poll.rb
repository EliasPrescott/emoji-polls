class Poll < ApplicationRecord
  belongs_to :user
  has_many :options, dependent: :delete_all
  has_many :option_votes, dependent: :delete_all
end
