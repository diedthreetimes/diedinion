module Cards
	class Deck
		
		include Enumerable
		
		def initialize
			@draw = []
			@discard = []
		end
		
		def clone
			ret = Deck.new
			each do |c|
				ret + c.clone
			end
			
			ret
		end
		
		def each &block
			@draw.each &block
			@discard.each &block
		end
		
		def draw_size
			@draw.size
		end
		
		def discard_size
			@discard.size
		end
		
		def count
			draw_size + discard_size
		end
		
		alias :size :count
		
		def + card
			@draw.concat [*card]
			
			self
		end
		
		def to_a
			@draw + @discard
		end
		
		def - card
			@draw.delete_one(card) || @discard.delete_one(card)
		end
		
		def gain card
			@discard.push card
		end
		
		def add_on_top c
			@draw.push c
		end
		
		def draw
			# Eventually this is probably not necessary
			# And should be removed
			begin
				shuffle if @draw.empty?
				card = @draw.pop
			end while card && card.trashed?
			
			card
		end
		
		def shuffle
			@draw.concat @discard
			@discard.clear
			
			@draw.shuffle!
			
			self
		end
		
		def sort
			@draw = @draw.sort_by{|x| x.cost}
			
			self
		end
		
		def discard card			
			@discard.push(card)
		end
		
		def victory
			select{|c| c.types.include? VictoryType}
		end
		
		def treasure
			select{|c| c.types.include? TreasureType}
		end
		
		def [] sel
			@draw [sel]
		end
		
		def self.load cards
			deck = Deck.new
			for param in cards do
				param[2] = Money.from_str( param[2].to_s )
				param[4] = Money.from_str( param[4].to_s )
				deck + (Card.new *param )
			end
			
			deck
		end
		
		def to_s
			ans = ""
			each_with_index {|x, i| ans += ("#{i}: " +x.to_s + "\n") }
			
			ans
		end
		alias to_str to_s
	end
end