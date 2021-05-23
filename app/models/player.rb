class Player < ApplicationRecord

	has_many :match_wons, :dependent => :destroy

	def total_match_played
		# Match.where(:player1_id => self.id).count + Match.where(:player2_id => self.id).count
		records = execute_statement(
			"SELECT count(*) AS total_played
			FROM (
			SELECT matches.player1_id AS player,
			       players.name AS name
			FROM   players 
			JOIN   matches
			ON     players.id=matches.player1_id
			UNION ALL
			SELECT matches.player2_id AS player,
			       players.name AS name
			FROM   players 
			JOIN   matches
			ON     players.id=matches.player2_id
			) AS p
			WHERE player = #{self.id}  
			GROUP BY player, name
			ORDER BY player;")
		return records.values.blank? ? 0 : records.getvalue(0,0)
	end

	def wins_matches
		self.match_wons.count
	end

	def loss_matches
		(self.played - self.wins_matches)
	end

	def get_score
		player_1 = matches.where(:player1_id => self.id).pluck(:player1_score)
		player_2 = matches.where(:player2_id => self.id).pluck(:player2_score)
		list_score = player_1+player_2
	end

	def average_score
		get_score.reduce(:+).to_f / get_score.size
	end

	def highest_score
		get_score.max
	end

	def execute_statement(sql)
	  results = ActiveRecord::Base.connection.execute(sql)

	  if results.present?
	    return results
	  else
	    return nil
	  end
	end

  def name_or_email
    uname = name.to_s.length == 0 ? email.split("@").first : name rescue "¯\_(ツ)_/¯"
    uname.titleize
  end

  def matches
    Match.where('player1_id = ? OR player2_id = ?', self.id, self.id)
  end

  def played
    matches.count
  end
end
