class Option < ApplicationRecord
  belongs_to :poll
  belongs_to :user
  has_many :option_votes, dependent: :delete_all

  # This regex is a best-effort attempt at matching most emojis without allowing too much nonsense.
  # Trying to properly handle all possible valid "emojis sequences" would be a nightmare.
  validates :content, format: { with: /\A\p{Emoji}(\u200D\p{Emoji}){0,5}\uFE0F?\z/, message: "must be a single valid emoji" }
end
