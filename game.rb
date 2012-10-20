class Game

	attr_reader :players, :cards

	def initialize n_players, cards
		@players = n_players.times.collect{Players::Human.new(self)}
		@cards = cards
		@cards.each{|x| x.set(10)}
		@cards.victory.each{|x| x.set( 4 + players.length*2)}
		@cards.find{|x| x.name == "Curse"}.set(5*players.length)
		@cards.treasure.each{|x| 
			if x.name == "Copper" || x.name == "Silver" || x.name == "Gold" || x.name == "Platinum"
				x.set( 30 ) # TODO: what is this really 
			end
		}
		
		@cards.sort
	end
	
	# Main loop, we may want to add some form of logger that shows what actions people have
	def play
		while !gameover? do
			for p in players
				@cur_p = p
				puts "#{@cur_p.name}'s turn"
				
				p.new_turn
				p.action_phase
				p.buy_phase
				p.end_turn
				
				if gameover?
					break;
				end
				
			end
		end
		
		# TODO: Fix this bit
		for p in players
			puts p.points
		end
		
	end
	
	def to_str
		@cards.to_s
	end
	
	
	def buy sel, player
		card = @cards[sel]
		if card.count == 0
			return false
		end
			
		if !card.can_buy? player
			return false
		end
			
		card.dec
		
		card.clone.set(1)
	end
	
	def gameover?
		colony = !@cards.find{|c| c.name == "Colony"}.nil?
		@cards.select{|c| c.gone?}.size > 2 || 
			@cards.find{|c| c.name == "Providence"}.gone? ||
			(colony && @cards.find{|c| c.name == "Colony"}.gone? )
	end
	
	def active_player
		@cur_p
	end
	
end