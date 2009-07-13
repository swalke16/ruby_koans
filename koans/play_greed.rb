require 'greed_game'

game = GreedGame.new ConsoleIODevice.new, ScoreKeeper.new
game.establish_players()
game.play()