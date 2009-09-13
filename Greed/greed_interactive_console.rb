$:.unshift File.join(File.expand_path(File.dirname(__FILE__)), "lib")
require 'greed_console'

game_ui = GreedGameConsoleUI.new(GreedGame.new())
game_ui.play()