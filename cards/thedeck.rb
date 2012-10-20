# Use a testing framework to quickly test each card
module Cards
$thedeck = Deck.load [
# Name, Type, cost, +actions, +coin, +buy, +card, vp
["Providence", VictoryType, 8, 0, 0, 0, 0, 6],
["Duchy", VictoryType, 5, 0, 0, 0, 0, 3],
["Estate", VictoryType, 2, 0, 0, 0, 0, 1],
["Gold", TreasureType, 6, 0, 3, 0, 0, 0],
["Silver", TreasureType, 3, 0, 2, 0, 0, 0],
["Copper", TreasureType, 0, 0, 1, 0, 0, 0, lambda {|p,c| p.copper = true}],
["Potion", TreasureType, 4, 0, "1p", 0, 0, 0,lambda {|p,c| p.potion = true}],
["Curse", nil, 0, 0, 0, 0, 0, -1]
]

$extra = Deck.load [
["Village", ActionType, 3, 2, 0, 0, 1, 0 ],
["MiningVillage", ActionType, 4, 2, 0, 0, 1, 0, lambda {|p,c|
    case p.choose("Trash this card for +2 coin:[y/n] ", ['y', 'n'])
      when 'y' then c.trash; p.add(Money.new(2, 0)); false
      when 'n' then true
    end
  }
],
["Festival", ActionType, 5, 2, 2, 1, 0, 0 ],
["Grand Market", ActionType, 6, 1, 2, 1, 1, 0, nil, lambda{|p,c| p.coin >= (Money.new(6, 0)) && !p.copper?}],
["Minion", [ActionType, AttackType], 5, 1, 0, 0, 0, 0, lambda {|p,c|
    case p.choose("Discard hand and draw 4; +2 coin :[1|2] ", ['1','2'])
      when '1' then  p.discard_hand; p.draw(4)
        c.set_attack {|p, c| p.discard_hand }
      when '2' then  p.add(Money.new(2,0))
        c.set_attack {|p,c| nil } # This is for attack reactions
      else raise ChoiceError.new
    end
  }
],
["Smithy", ActionType, 4, 0, 0, 0, 3, 0],
["Loan", TreasureType, 3, 0, 1, 0, 0, 0, lambda {|p,c|
    card = p.draw
    while ( card && !card.types.include?(TreasureType) ) do
      p.discard_c card
      card = p.draw
    end
    if !card.nil?
      case p.choose("#{card.name}, Discard or Trash :[1|2] ", ['1','2'])
        when '1' then p.discard_c card
        when '2' then p.discard_c card; card.trash
      end
    end
  }
],
["Alchemist", ActionType, "1p3", 1, 0, 0, 2, 0, nil, nil, nil, lambda{|p,c|
    # Check this condition specifically
    if p.potion?
      case p.choose("Place #{c.name} on top?:[y|n] ", ['y','n'])
        when 'y' then p.deck.add_on_top(c); false
        when 'n' then true
      end
    else
      true
    end
  }
],
["Kings Court", ActionType, "7", 0, 0, 0, 0, 0, lambda {|p,c|
    card = p.select_card(ActionType, "Chose a card to play three times: ", false)
     3.times { p.play( card ) }
  }
],
["Market", ActionType, "5", 1, 1, 1, 1, 0 ]

# Need machinery for talisman, highway, bridge, city (maybe)
]

$prosperity = Deck.load [
["Colony", VictoryType, 11, 0, 0, 0, 0, 11],
["Platinum", TreasureType, 9, 0, 5, 0, 0, 0]
]
end
