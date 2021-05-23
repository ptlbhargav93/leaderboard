class Match < ApplicationRecord
	belongs_to :player1, :class_name => 'Player'
	belongs_to :player2, :class_name => 'Player'
	belongs_to :winner, :class_name => 'Player'
	has_one :match_won, :dependent => :destroy

	after_save :upsert_match_won

	before_validation :set_winner
	validate :validate_player

	WINNING_SCORE  = 21
  MIN_SCORE_DIFF = 2

	validates_presence_of :player1, :player2, :player1_score, :player2_score, :date_played

	validate :min_score
  validate :max_score
  validate :winning_difference

  after_create :set_elo_rankings

  def scores
	    return "#{player1_score}-#{player2_score}"
	end

	def game_result
	    if player1_score > player2_score
	    	"W - player1"
	    elsif player2_score > player1_score
	    	"W - player2"
	   	end
	end

	def upsert_match_won
		self.match_won.present? ? self.match_won.update(:player => self.winner) : self.create_match_won(:player => self.winner)
	end

	def set_winner
		self.winner = player1_score > player2_score ? player1 : player2
	end

	private

	def validate_player
		if (self.player1_id == self.player2_id)
			self.errors.add(:player, "should not be same") 
			return false
		end
	end
    
    def min_score
      if player1_score < WINNING_SCORE and player2_score < WINNING_SCORE
        errors.add(:min_score, "The score needs to be min 21 for one of the players")
      end
    end

    def max_score
      if (player1_score > WINNING_SCORE || player2_score > WINNING_SCORE) and (player1_score - player2_score).abs > MIN_SCORE_DIFF
        errors.add(:max_score, "The score cannot be greater than 21 if the difference of the scores is greater that 2")
      end
    end

    def winning_difference
      if (player1_score - player2_score).abs < MIN_SCORE_DIFF
        errors.add(:winning_difference, "You have to win or lose for more than 2 points")
      end
    end

    def set_elo_rankings(k_value=32)
      # As taken from the example provided in the README: https://github.com/rgho/elo.rb/blob/master/elo.rb

      # Assign actual individual results
      result = 0
      result = 1 if player1_score > player2_score
      player_1_result = result
      player_2_result = 1 - result

      # Calculate expected results
      player1_expectation = 1.0/(1+10**((player2.ranking - player1.ranking)/400.0)) #the .0 is important to force float operations!))
      player2_expectation = 1.0/(1+10**((player1.ranking - player2.ranking)/400.0))

      # Calculate new rankings
      player1_new_ranking = player1.ranking + (k_value*(player_1_result - player1_expectation))
      player2_new_ranking = player2.ranking + (k_value*(player_2_result- player2_expectation))

      # Not optional rounding
      player1_new_ranking = player1_new_ranking.round
      player2_new_ranking = player2_new_ranking.round

      # Set the new ranking and do so!
      player1.update_attribute(:ranking, player1_new_ranking)
      player2.update_attribute(:ranking, player2_new_ranking)
    end

end
