require 'greed_game'

game = GreedGame.new StandardIODevice.new, ScoreKeeper.new
game.establish_players()
game.play()