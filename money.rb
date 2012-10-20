class Money

	attr_reader :coin, :potion

	def initialize coin = 0, potion = 0
		@coin = coin.to_i
		@potion = potion.to_i
		
		self
	end
	
	def self.from_str str
		sp = str.to_str.split("p")
		if(str =~ /p/)
			potion = sp[0].to_i
			coin = sp[1].to_i
		else
			coin = sp[0].to_i
			potion = 0
		end
		
		new(coin, potion)
	end
	
	def + o
		Money.new(@coin + o.coin, @potion + o.potion)
	end
	
	def - o
		Money.new(@coin - o.coin, @potion - o.potion)
	end
	
	def == o
		o.coin == @coin && o.potion == @potion
	end
	
	def < o
		(@coin < o.coin && @potion <= o.potion) || (@coin <= o.coin && @potion < o.potion)
	end
	
	def > o
		(@coin > o.coin && @potion >= o.potion) || (@coin >= o.coin && @potion > o.potion)
	end
	
	def >= o
		self > @other || self == o
	end
	
	def <= o
		self < o || self == o
	end
	
	def <=> o
		if self > o
			1
		elsif self == o
			0
		elsif self < o
			-1
		else # This can happen if we have coins vs potions
			0
		end
	end
	
	def to_s
		if @potion > 0
			@potion.to_s + "p" + @coin.to_s
		else
			@coin.to_s
		end
	end
end