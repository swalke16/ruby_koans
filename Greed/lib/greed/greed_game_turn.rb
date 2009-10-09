class GreedGameTurn
  attr_reader :score
  attr_reader :was_lost
  attr_reader :dice_left_to_roll

  def initialize(dice)
    @score = 0
    @was_lost = false
    @dice_left_to_roll = 5
    @dice = dice
  end

  def play(player)
    while @dice_left_to_roll > 0 && player.wants_to_roll_again?(self)
      @dice.roll(@dice_left_to_roll)
      @dice_left_to_roll = @dice.number_of_non_scoring

      if @dice.score > 0
        @score += @dice.score
      else
        @was_lost = true
        @score = 0
        break
      end
    end
  end
end