require 'greed/console_player_strategy'

class SimpleAIConsolePlayerStrategy < ConsolePlayerStrategy
   def wants_to_roll_again?(player, turn_score, dice_left_to_roll)
    true
   end
end