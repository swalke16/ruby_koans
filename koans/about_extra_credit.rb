# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.

# NOTE ******
# The game has been implemented with all classes in greed_game.rb
# A full suite of RSpec tests for the game can be executed by running
#
# spec greed_game_spec.rb --format specdoc
# 
#The game can be played interactively from the console by running
#
# ruby play_greed.rb
#
# enjoy! it's been fun!!!

#  Additional note:
#
# In the process of continuing my learning of ruby I've gone ahead and created a
# greed v2 implementation that better separates out the UI concerns so that I can
# at some point put some different interfaces (like a web UI) on top of it. I also
# attempted to setup a more realistic project structure for the app as well as
# adding a Rakefile to run all the specs... The Rakefile is not working at the moment.
#
# The v2 version of the game is mostly finished (minus some TODO comments in the code)
# and is fully playable from the console ui. It can be found in the <greed> folder at
# the peer folder level to the <koans> folder.