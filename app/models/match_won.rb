class MatchWon < ApplicationRecord
  belongs_to :match
  belongs_to :player
end