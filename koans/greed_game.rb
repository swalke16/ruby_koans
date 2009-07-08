class GreedGame
  def initialize(io_device, scorekeeper)
    raise ArgumentError, "IO device cannot be nil!" if io_device == nil
    raise ArgumentError, "IO device must respond to get_input!" if !io_device.respond_to? :get_input
    raise ArgumentError, "IO device must respond to write_output!" if !io_device.respond_to? :write_output
    raise ArgumentError, "scorekeeper can not be nil and must be kind_of? ScoreKeeper!" if scorekeeper == nil || !scorekeeper.kind_of?(ScoreKeeper) 

    @io_device = io_device
    @scorekeeper = scorekeeper
  end

  def establish_players()
    @io_device.write_output %{
Welcome to the game of Greed!
Please enter player names, or a blank name to stop creating players.
Enter player #{@scorekeeper.players.length + 1} name:}
    player_name = @io_device.get_input
    while player_name != ""
      @scorekeeper.add_player(player_name.chomp)
      @io_device.write_output "Enter player #{@scorekeeper.players.length  + 1} name:"
      player_name =  @io_device.get_input
    end
  end

  def play()
    if @scorekeeper.players.length < 2
      @io_device.write_output %{
To play this game you must have 2 or more players!
Please establish players before starting a game.\n\n}
      return
    end

    # process all turns leading up to final round
    while !is_final_round?
      give_all_players_a_turn_unless {is_final_round?}
    end

    # process final round
    leading_player = @scorekeeper.player_has_winning_score?
    @io_device.write_output %{
#{leading_player} has scored greater than 3000 points!
The game is now entering the final round in which all players except #{leading_player} will have one final turn.
    }
    give_all_players_a_turn_unless {|player_name| player_name == leading_player}

    # display game summary info  
    @io_device.write_output %{
The game has now ended!
#{@scorekeeper.score_summary}}
  end

  private
  def give_all_players_a_turn_unless (&unless_predicate)
    @scorekeeper.players.each do |player_name|
      if !unless_predicate.call(player_name)
        turn = @scorekeeper.turn_is_starting_for(player_name)
        turn.play(@io_device)
        @scorekeeper.turn_is_ending_for(player_name, turn)
      end
    end
  end

  def is_final_round?
    true if @scorekeeper.player_has_winning_score? != nil
  end
end

class GreedGameTurn
  attr_reader :score

  def initialize(player, scorekeeper, dice)
    raise ArgumentError, "player can not be nil and must be kind_of? Player!" if player == nil || !player.kind_of?(Player)
    raise ArgumentError, "scorekeeper can not be nil and must be kind_of? ScoreKeeper!" if scorekeeper == nil || !scorekeeper.kind_of?(ScoreKeeper)
    raise ArgumentError, "dice can not be nil and must be kind_of? Dice!" if dice == nil || !dice.kind_of?(DiceSet)

    @score = 0
    @player = player
    @scorekeeper = scorekeeper
    @dice = dice
  end

  def play(io_device)
    non_scoring_dice = 5

    while non_scoring_dice > 0 && player_chooses_to_roll_again?(io_device, non_scoring_dice)
      @dice.roll(non_scoring_dice)
      roll_score, non_scoring_dice = @scorekeeper.score_roll(@dice.values)

      if roll_score > 0
        @score += roll_score
      else
        io_device.write_output "You rolled a zero so you lost your turn and any accumulated score for this turn."
        @score = 0
        break
      end
     end
  end

  private
  def display_player_info(io_device)
    io_device.write_output "#{@player.name}'s turn! In Game: #{@player.in_game} Game Score: #{@player.score} Turn Score: #{@score}\n"
  end

  def player_chooses_to_roll_again?(io_device, available_dice)
    display_player_info(io_device)
    io_device.write_output "You have #{available_dice} dice left to roll. Roll dice? (y/n):"
    player_chose_to_roll_again = io_device.get_input.chomp == "y"
  end
end

class Player
  attr_reader :name
  attr_reader :score
  attr_reader :in_game

  def initialize(name)
    @name = name
    @score = 0
    @in_game = false
  end

  def update_score(points)
    @in_game = true if points >= 300 && !@in_game
    @score += points unless !@in_game
  end
end

class DiceSet
  attr_reader :values
  def roll(n)
    @values = (1..n).map { rand(6) + 1 }
  end
end

class ScoreKeeper
  def initialize()
    @players = []
  end

  def add_player(name)
    @players << Player.new(name)
  end

  def players
    @players.map {|player| player.name}
  end

  def turn_is_starting_for(player_name)
    player = find_player(player_name)
    GreedGameTurn.new player, self, DiceSet.new
  end

  def turn_is_ending_for(player_name, turn)
    player = find_player(player_name)
    player.update_score(turn.score)
  end

  def score_roll(dice)
    digit_counts = count_digits(dice)
    digit_scores = digit_counts.inject({}){|h,(k,v)| h[k] = score_for_digit(k,v); h }
    turn_score = digit_scores.values.inject(0){|sum,item| sum + item}
    non_scoring_count = digit_scores.inject(0){|sum,(k,v)| v==0 ? sum + digit_counts[k] : sum}
    return turn_score, non_scoring_count
  end

  def score_for_player?(player_name)
    player = find_player(player_name)
    player.score
  end

  def player_has_winning_score?
    players = @players.select {|player| player.score >= 3000}
    players.length > 0 ? players[0].name : nil
  end

  def score_summary
    leading_player = @players.inject {|lead, player| player.score > lead.score ? player : lead}
    @players.inject("Game Summary:\n") do |text, player|
       text << "#{player.name} scored: #{player.score} points."
       text << " -- WINNER!" if player == leading_player
       text << "\n"
    end
  end
private
  def find_player(player_name)
    player = @players.select {|player| player.name == player_name}[0]
    raise ArgumentError, "No player by the name #{player_name} is playing this game!" if player == nil
    return player
  end

  def count_digits(dice)
    digit_counts = Hash.new(0)
    dice.each{ |item| digit_counts[item] += 1 }

    return digit_counts
  end

  def score_for_digit(digit, count)
    score=0

    if count >= 3
      score += triple_digit_score(digit) + sum_digit_score(digit, count-3)
    else
      score += sum_digit_score(digit, count)
    end

    return score
  end

  def triple_digit_score(digit)
    if digit == 1
      1000
    else
      digit * 100
    end
  end

  def sum_digit_score(digit, count)
    if digit == 1
      count*100
    elsif digit == 5
      count*50
    else
      0
    end
  end
end

class StandardIODevice
  def get_input
    gets.chomp
  end

  def write_output(output)
    puts output
  end
end