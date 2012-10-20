require 'cards/card'
require 'cards/deck'

require 'money'

module Cards
	def self.random_deck(num = 10)
		d = Deck.new
		
		e = $extra.clone.shuffle
		
		num.times do 
			d + e.draw
		end
		
		d
	end
	
	
	def self.standard
		$thedeck.clone
	end
	
	def self.prosperity
		$prosperity.clone
	end
	
	def self.find &block
		$thedeck.find(&block) || $extra.find(&block) || $prosperity.find(&block)
	end
end

require 'cards/thedeck'
