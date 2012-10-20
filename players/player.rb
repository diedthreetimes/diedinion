module Players

#TODO: Extract selection to human and AI
class Player

	attr_accessor :coin, :actions, :buys, :copper, :potion
	attr_reader :hand, :deck, :play, :side_board, :name

	# TODO: Move on if no cards can be selected
	def initialize game
		@deck = Cards::Deck.new
		3.times do
			@deck + Cards.find{|c| c.name == "Estate"}.clone
		end
		7.times do
			@deck + Cards.find{|c| c.name == "Copper"}.clone
		end
		@deck.shuffle
		@hand = []
		@play = []
		
		@game = game
		
		@name = choose("What is your name?: ", nil)
		
		draw_to 5
	end

	def choose text, choices = nil, &block
		while true
			print text
		
			ans = $stdin.gets.strip
			if block && block.call(ans)
				return ans
			elsif !block && choices.nil?
				return ans
			elsif !block && choices.include?(ans)
				return ans
			else
				puts "Entry invalid. Please Try Again"
			end
		end
	end
	
	def draw num = 1
		card = nil
		
		num.times {
			card = @deck.draw
			@hand.push( card ) if card
		}
		
		card
	end
	
	def draw_to num
		draw num - @hand.count
	end
	
	# Add s option
	def select_card type, msg = nil, no_option = true
	
		if @hand.select{|c| c.types.include? type}.empty? 
			return nil
		end
		
		if msg.nil?
			msg = "Please select a #{type} card:[0..#{@hand.count-1}"
			msg += "|n" if no_option
			msg += "] "
		end
		
		@hand.each_with_index{|x,i|
			puts "#{i}: #{x}"
		}
		
		card = choose(msg) {|s|
			(no_option && s == 'n') || (@hand[s.to_i] && @hand[s.to_i].types.include?(type)) ||
				s == "d"
		}
		
		if card == 'n'
			nil
		elsif card == "d"
			print_state
			nil
		else
			@hand[card.to_i]
		end 
	end
	
	def new_turn
		@actions = 1
		@coin = Money.new(0, 0)
		@buys = 1
		
		@copper = false
		@potion = false
		# @side_board.each{|c| c.second_action(self) }
	end
	
	def action_phase

		while( @actions > 0 && (card = select_card(Cards::ActionType)) ) do
			@actions -= 1
			play( card )
		end
		
	end
	
	def buy_phase
		# choose( "Play #{hand.treasures.coin}?:[y/n] ", [y/n]
		while( card = select_card(Cards::TreasureType) ) do
			play( card )
		end
		
		while( buys > 0 && (choice = choose( "Buy a card?:[#|l|n|s] ") ) ) do
			if choice == "n"
				return
			elsif choice == "l"
				puts @game.to_str # Highlight what you can buy
			elsif choice == "s"
				puts "#{actions} actions - #{buys} buys - #{coin} coin"
			elsif choice == "d"
				print_state
			elsif choice =~ /^[0-9]+/ && (card = @game.buy( choice.to_i, self ))
				@buys -= 1
				if card.on_buy(self)
					@coin -= card.cost
					gain card
				end
			else
				say "Illegal Buy"
			end
		end
	end
	
	def end_turn
		@play.each do |c|
			if(c.on_cleanup(self))
				@deck.discard c
			end
		end
		
		@play.clear
		
		discard_hand
		draw_to 5
	end
	
	def gain card
		if( !card.on_gain self )
			return
		end
			
		@deck.gain card
	end
	
	def say msg
		puts msg
	end
	
	def play card
		# TODO: verify this actually works when used with throne room /kings court
		# signs show it doesn't
		@play.push card
		@hand.delete_one card
		
		if(!card.play_special(self))
			return
		end
		
		for p in @game.players
			next if p == self
			card.attack p
		end
		
		@actions += card.actions
		@buys += card.buy
		@coin += card.coin
		
		draw card.cards
	end
	
	def copper?
		@copper
	end
	
	def potion?
		@potion
	end
	
	
	def discard num = 1
		if num < 1
			say "No discard necessary"
		else
			max(num, @hand.count).times do 
				card = select_card(nil, "Select a card to discard", false)
				
				discard_c card
			end
		end
	end
	
	def discard_to num
		discard (@hand.count - num)
	end
	
	def discard_hand
		@hand.each do |c|
			@deck.discard c
		end
		
		@hand.clear
	end
	
	def discard_c card
		@hand.delete_one card
		
		if(card.on_discard(self))
			@deck.discard card
		end
	end
	
	
	def points
		discard_hand
		@deck.shuffle 
		@deck.victory.inject(0){|s,x| s+= x.victory_points}
	end
	
	def add coin
		@coin += coin
	end
	
	def reactions?
		while( card = select_card(Cards::ReactionType) ) do
			@actions -= 1
			play( card )
		end
	end
	
	def print_state
		puts "Hand"
		@hand.each{|c| puts "\t" + c.name}
		puts "Deck"
		deck.each{|c| puts "\t" + c.name}
		puts "Play"
		@play.each{|c| puts "\t" + c.name}
	end
	
end

end