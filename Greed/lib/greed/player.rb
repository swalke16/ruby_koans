require 'greed/greed_game_turn'
require 'greed/diceset'

class Player
  attr_reader :name
  attr_reader :score
  attr_reader :in_game

  def initialize(name)
    @name = name
    @score = 0
    @in_game = false
  end

  def play_turn(dice, game_ui)
    raise ArgumentError, "dice can not be nil" if dice == nil
    raise ArgumentError, "game_ui can not be nil!" if game_ui == nil

    turn = GreedGameTurn.new(self, game_ui)
    turn.play(dice)
    update_score(turn.score) unless turn.was_lost
  end

  private
  
  def update_score(points)
    @in_game = true if points >= 300 && !@in_game
    @score += points unless !@in_game
  end
end