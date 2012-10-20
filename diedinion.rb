#!/usr/bin/env ruby
$:.unshift File.dirname(__FILE__)
require 'money'
require 'players'
require 'cards'
require 'game'

class Diedinion

  attr_reader :game, :kingdom_cards

  def initialize
    ask_players
    ask_colony

    @kingdom_cards = Cards.random_deck + Cards.standard
    @kingdom_cards + Cards.prosperity if @colony

    @game = Game.new( @num_players, @kingdom_cards )
  end

  def start
    #Start the main game loop
    @game.play

    self
  end

  def get_int( query, min = 0, max = 0, &block )
    print query

    ans = $stdin.gets.to_i
    if block && block.call(ans)
      return ans
    elsif ans >= min && ans <= max
      return ans
    else
      puts "Entry invalid. Please Try Again."
      get_int( query, min, max, &block )
    end
  end

  def ask_players
    @num_players = get_int("How many players: ", 1, 4)
  end

  def ask_colony
    @colony = get_int("Would you like to play with Colonies [0/1]: ", 0, 1) == 1
  end

end

$game = Diedinion.new.start
