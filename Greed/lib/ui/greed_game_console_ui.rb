# TODO: create another UI on top

require 'rubygems'
require 'highline'
require 'greed'

class GreedGameConsoleUI

  def initialize(greed_game_engine)
    @game_engine = greed_game_engine
    @terminal = HighLine.new
  end

  def play()
    display_game_info()
    players = prompt_for_players()
    
    begin
      @game_engine.play(self, players)
      display_game_summary()
    rescue ArgumentError => error
      @terminal.say("\n")
      @terminal.say(%{<%= color("#{error}", :red) %>})
    end      
  end

  def entering_final_round(leading_player)
    @terminal.say(%{
<%= color('#{leading_player.name}', :yellow) %> has scored greater than 3000 points!
The game is now entering the final round in which all players except <%= color('#{leading_player.name}', :yellow) %> will have one final turn.})
    @terminal.say("\n")
  end

private
  def display_game_info()
    @terminal.say("\n")
    @terminal.say("Welcome to the game of <%= color('Greed', :green) %>!")
    @terminal.say("\n")
  end

  def prompt_for_players()
    @terminal.say("Please enter player names, or a blank name to stop creating players.")

    players = []
    player_name = nil
    begin
      while player_name != ""
        player_name = @terminal.ask("Enter player <%= color('#{players.length + 1}', :yellow) %> name: ")
        players << player_name unless player_name == ""
      end
    rescue EOFError
    end

    @terminal.say("\n")

    return players.map {|name| GreedPlayer.new(name, HumanConsolePlayerStrategy.new(@terminal))}
  end

  def display_game_summary()
    @terminal.say("The game has now ended!")

    winning_player = @game_engine.players.inject {|lead, player| player.score > lead.score ? player : lead}
    summary = @game_engine.players.inject("Game Summary:\n") do |text, player|
       text << "<%= color('#{player.name}', :yellow) %> scored: <%= color('#{player.score}', :yellow) %> points."
       text << "<%= BLINK %><%= color(' <-- WINNER!', :magenta) %><%= CLEAR %>" if player == winning_player
       text << "\n"
    end
    
    @terminal.say(summary)
    @terminal.say("\n")
  end

end