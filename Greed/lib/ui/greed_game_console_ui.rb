# TODO: create another UI on top
# TODO: allow default input to be "y" without blank line
# TODO: fix overwrite issues on display
# TODO: better display of player status after every roll

class GreedGameConsoleUI

  def initialize(greed_game_engine)
    raise ArgumentError, "Game engine cannot be nil!" if greed_game_engine == nil
    @game_engine = greed_game_engine
  end

  def play()
    display_game_info()
    players = prompt_for_players()
    
    begin
      @game_engine.play(self, players)
      display_game_summary()
    rescue ArgumentError => error
      write_line("")
      write_line(error)
    end      
  end

  def turn_starting(turn)
    display_turn_status(turn)
  end

  def player_wants_to_roll_again?(turn)
    write "You have #{turn.dice_left_to_roll} dice left to roll. Roll dice? ((y)/n): "
    get_input.chomp.downcase == "y"
  end

  def turn_ending(turn)
    if turn.was_lost
      display_lost_turn()
    else
      display_turn_ending(turn)
    end
  end

  def entering_final_round(leading_player)
    write_line %{
#{leading_player.name} has scored greater than 3000 points!
The game is now entering the final round in which all players except #{leading_player.name} will have one final turn.
    }
  end

private
  def display_game_info()
    write_line ""
    write_line "Welcome to the game of Greed!"
    write_line ""
  end

  def prompt_for_players()
    write_line "Please enter player names, or a blank name to stop creating players."

    players = []
    player_name = nil
    while player_name != ""
      write %{Enter player #{players.length + 1} name: }
      player_name = get_input()
      players << player_name unless player_name == ""
    end

    write_line ""

    return players.map {|name| Player.new(name)}
  end

  def display_lost_turn()
    write_line "You rolled a zero so you lost your turn and any accumulated score for this turn."
  end

  def display_turn_status(turn)
    write_with_overwrite "#{turn.player.name}'s turn! In Game: #{turn.player.in_game} Game Score: #{turn.player.score} Turn Score: #{turn.score}\n"
  end

  def display_turn_ending(turn)
    write_line "Your turn has now ended! You scored a total of #{turn.score} points for this turn!"
    write_line ""
  end

  def display_game_summary()
    write_line ""

    # display game summary info
    write_line "The game has now ended!"

    # should we move some of this logic inside the game engine?
    winning_player = @game_engine.players.inject {|lead, player| player.score > lead.score ? player : lead}
    summary = @game_engine.players.inject("Game Summary:\n") do |text, player|
       text << "#{player.name} scored: #{player.score} points."
       text << " -- WINNER!" if player == winning_player
       text << "\n"
    end
    
    write_line summary
  end

  def get_input
    !$stdin.eof? ? $stdin.readline.chomp : ""
  end

  def write(output)
    $stdout.write output
  end

  def write_line(output)
    $stdout.puts output
  end

  def write_with_overwrite(output, &block)
    $stdout.write output
    yield if block_given?
    $stdout.write "\b" * output.length;
  end
end