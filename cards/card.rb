module Cards
	VictoryType = 0
	TreasureType = 1
	ActionType = 2
	ReactionType = 3
	AttackType = 4
	
	#TODO: Think about having a card belong/use a deck and not a player
	#TODO: Think about using events and observer pattern to handle on_gain on_buy etc...
	
	# If any block returns false, the action is considered complete.
	class ChoiceError < RuntimeError; nil end
	class Card
		attr_reader :name, :types, :cost, :actions, :coin, :buy, :cards, :victory_points
		attr_reader :trashed, :count
		
		attr_writer :on_gain, :on_trash, :on_cleanup, :on_discard, :on_buy, :atk_action, :spec_action, :atk_action
		
		def initialize n, t, co, a, c, b, ca, vp, special_block = nil, precondition_block = nil, attack_block = nil, on_cleanup = nil, on_trash = nil, on_buy = nil, on_gain = nil, on_discard = nil
			@name = n
			@types = [*t]
			@cost = co
			@actions = a
			@coin = c
			@buy = b
			@cards = ca
			@victory_points = vp
			
			@spec_action = special_block
			@pre_cond = precondition_block
			@atk_action = attack_block 
			@on_discard = on_discard || lambda {|p, c| true}
			@on_cleanup = on_cleanup || lambda {|p, c| true}
			@on_trash = on_trash || lambda {|c| true}
			@on_buy = on_buy || lambda {|p, c| true}
			@on_gain = on_gain || lambda {|p, c| true}
			
			@trashed = false
			@count = 1
		end
		
		def set n
			@count = n
			
			self
		end
		
		def dec
			@count -= 1
			
			self
		end
		
		# This should work as is
		#def clone
			
		#end
	
		
		# We could change players state here
		def play_special player
			if @spec_action
				@spec_action.call player, self
			end
			
			true
		end
		
		def attack player
			if  @atk_action
				while player.reactions? ; end
			
				@atk_action.call(player, card)
			end
			
			true
		end
		
		def set_attack &block
			@atk_action = block
		end
		
		def can_buy? player
			(@precondition_block.nil? && @cost <= player.coin) || (@precondition_block && @precondition_block.call( player, self))
		end
		
		def trash
			@on_trash.call(self)
			
			@trashed = true
			
			# TOOD: Move to the global trash
		end
		
		def trashed?
			@trashed
		end
		
		def on_cleanup player
			@on_cleanup.call(player, self)
		end
			
		def on_discard player
			@on_discard.call(player, self)
		end
		
		#This is necessary for things like Ill-gotten gains
		def on_gain player
			@on_gain.call(player, self)
		end
		
		def on_buy player
			@on_buy.call(player, self)
		end
		
		def to_s
			ans = "#{@name} - #{@cost}"
			ans += "(" + @count.to_s + ")" if @count != 1
			
			ans
		end
		
		def gone?
			@count == 0
		end

	end
end