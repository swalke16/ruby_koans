class ConsolePlayer
  attr_reader :name
  attr_reader :score
  attr_reader :in_game

  def initialize(name, terminal)
    @name = name
    @score = 0
    @in_game = false
    @terminal = terminal
  end

  def play_turn(turn)
    turn.play(self)
    update_score(turn.score) unless turn.was_lost
    turn.was_lost ? display_lost_turn() : display_turn_ending(turn)
  end
  
  def wants_to_roll_again?(turn)
    @terminal.agree(%{<%= color("#{@name}'s", :yellow) %> turn! In Game: <%= color('#{@in_game}', :yellow) %> Game Score: <%= color('#{@score}', :yellow) %> Turn Score: <%= color('#{turn.score}', :yellow) %>
You have <%= color('#{turn.dice_left_to_roll}', :cyan) %> dice left to roll. Roll dice? <%= color('(y/n)', :cyan) %> }, true) do |q|
      q.overwrite = true
      q.echo      = false  # overwrite works best when echo is false.
      q.character = true   # if this is set to :getc then overwrite does not work
    end
  end

  private
  
  def update_score(points)
    @in_game = true if points >= 300 && !@in_game
    @score += points unless !@in_game
  end
  
  def display_lost_turn()
    @terminal.say("<%= color('You rolled a zero so you lost your turn and any accumulated score for this turn.', :red) %>")
    @terminal.say("\n")
  end

  def display_turn_ending(turn)
    @terminal.say("Your turn has now ended! You scored a total of <%= color('#{turn.score}', :green) %> points for this turn!")
    @terminal.say("\n")
  end  
end