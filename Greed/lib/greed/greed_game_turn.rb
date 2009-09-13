require 'greed/player'
require 'greed/diceset'

class GreedGameTurn
  attr_reader :score
  attr_reader :player
  attr_reader :was_lost
  attr_reader :dice_left_to_roll

  def initialize(player, game_ui)
    raise ArgumentError, "player can not be nil" if player == nil
    raise ArgumentError, "game_ui can not be nil!" if game_ui == nil

    @score = 0
    @player = player
    @was_lost = false
    @dice_left_to_roll = 5
    @game_ui = game_ui
  end

  def play(dice)
    raise ArgumentError, "dice can not be nil!" if dice == nil

    notify_turn_starting()

    while @dice_left_to_roll > 0 && player_wants_to_roll_again?
      dice.roll(@dice_left_to_roll)
      @dice_left_to_roll = dice.number_of_non_scoring

      if dice.score > 0
        @score += dice.score
      else
        @was_lost = true
        @score = 0
        break
      end
    end

    notify_turn_ending()
  end

  private
  def player_wants_to_roll_again?()
    raise ArgumentError, "game ui must respond to :player_wants_to_roll_again?" unless @game_ui.respond_to?(:player_wants_to_roll_again?)

    @game_ui.send(:player_wants_to_roll_again?, self)
  end

  def notify_turn_starting()
    if @game_ui.respond_to?(:turn_starting)
      @game_ui.send(:turn_starting, self)
    end
  end

  def notify_turn_ending()
    if @game_ui.respond_to?(:turn_ending)
      @game_ui.send(:turn_ending, self)
    end
  end
end