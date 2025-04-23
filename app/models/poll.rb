class Poll < ApplicationRecord
  belongs_to :user
  has_many :options, dependent: :destroy
  has_many :option_votes, dependent: :destroy
end
