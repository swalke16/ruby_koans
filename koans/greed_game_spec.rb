require "spec"
require "greed_game"

Spec::Runner.configure do |config|
  config.mock_with :flexmock
end

describe GreedGame, "when first created" do
  it "should be created" do
    game = GreedGame.new flexmock(:get_input=>"", :write_output=>""), flexmock( :kind_of? => ScoreKeeper )
    game.should_not be_nil
  end

  it "should raise ArgumentError if io_device is nil" do
    lambda { GreedGame.new nil, flexmock( :kind_of? => ScoreKeeper )}.should raise_error(ArgumentError, /nil/)
  end

  it "should raise ArgumentError if io_device does not respond to get_input" do
    io_device = flexmock(:write_output=>"")
    lambda { GreedGame.new io_device, flexmock( :kind_of? => ScoreKeeper ) }.should raise_error(ArgumentError, /get_input/)
  end

  it "should raise ArgumentError if io_device does not respond to write_output" do
    io_device = flexmock(:get_input=>"")
    lambda { GreedGame.new io_device, flexmock( :kind_of? => ScoreKeeper ) }.should raise_error(ArgumentError, /write_output/)
  end

  it "should raise ArgumentError if scorekeeper is nil or not kind_of? ScoreKeeper" do
    lambda { GreedGame.new flexmock(:get_input=>"", :write_output=>""), nil }.should raise_error(ArgumentError, /scorekeeper can not be nil/)
    lambda { GreedGame.new flexmock(:get_input=>"", :write_output=>""), Object.new }.should raise_error(ArgumentError, /scorekeeper can not be nil/)
  end
end

describe GreedGame, "when establishing players" do 
  it "should prompt for player names until no names entered and add players to scorekeeper" do
    io_device = flexmock("FakeIO", :write_output=>"")
    io_device.should_receive(:get_input).with_no_args.and_return("tom", "dick", "harry", "")
    scorekeeper = flexmock( :kind_of? => ScoreKeeper)
    scorekeeper.should_receive(:add_player).once.with("tom").ordered
    scorekeeper.should_receive(:add_player).once.with("dick").ordered
    scorekeeper.should_receive(:add_player).once.with("harry").ordered
    scorekeeper.should_receive(:players).and_return(["tom", "dick", "harry"])
    game = GreedGame.new io_device, scorekeeper

    game.establish_players
  end
end

describe GreedGame, "when playing the game with less than two players established" do
  it "should display warning message and stop immediately" do
    io_device = flexmock("FakeIO")
    io_device.should_receive(:respond_to?).once.with(:get_input).and_return(true)
    io_device.should_receive(:respond_to?).once.with(:write_output).and_return(true)
    scorekeeper = flexmock("fake scorekeeper", :kind_of? => ScoreKeeper)
    io_device.should_receive(:write_output).once.with(/2 or more players/)
    scorekeeper.should_receive(:players).at_least.once.and_return([""])
    game = GreedGame.new io_device, scorekeeper

    game.play()
  end
end

describe GreedGame, "when playing the game with three players tom, dick, and harry"   do
  before(:each) do
    @io_device = flexmock("FakeIO")
    @io_device.should_receive(:respond_to?).once.with(:get_input).and_return(true)
    @io_device.should_receive(:respond_to?).once.with(:write_output).and_return(true)
    @scorekeeper = flexmock("fake scorekeeper", :kind_of? => ScoreKeeper)
    @scorekeeper.should_receive(:players).at_least.once.and_return(["tom", "dick", "harry"])
    @turn = flexmock("fake turn", :play=>nil)
    @game = GreedGame.new @io_device, @scorekeeper
  end

  it "should give every player a turn to roll until a player has a winning score (>= 3000)" do
    @scorekeeper.should_receive(:player_has_winning_score?).and_return(nil,nil,nil,nil,"tom")
    @scorekeeper.should_receive(:turn_is_starting_for).at_least.once.with("tom").and_return(@turn).ordered(:turns)
    @scorekeeper.should_receive(:turn_is_ending_for).at_least.once.with("tom", @turn).ordered(:turns)
    @scorekeeper.should_receive(:turn_is_starting_for).at_least.once.with("dick").and_return(@turn).ordered(:turns)
    @scorekeeper.should_receive(:turn_is_ending_for).at_least.once.with("dick", @turn).ordered(:turns)
    @scorekeeper.should_receive(:turn_is_starting_for).at_least.once.with("harry").and_return(@turn).ordered(:turns)
    @scorekeeper.should_receive(:turn_is_ending_for).at_least.once.with("harry", @turn).ordered(:turns)
    @io_device.should_receive(:write_output).once.with(/tom has scored greater than 3000/)
    @io_device.should_receive(:write_output).zero_or_more_times
    @scorekeeper.should_ignore_missing

    @game.play()
  end

  it "should give every player other than the leading player one more turn once a player has a winning score (>= 3000)" do
    @scorekeeper.should_receive(:player_has_winning_score?).and_return("tom")
    @scorekeeper.should_receive(:turn_is_starting_for).never.with("tom").and_return(@turn).ordered(:turns)
    @scorekeeper.should_receive(:turn_is_ending_for).never.with("tom", @turn).ordered(:turns)
    @scorekeeper.should_receive(:turn_is_starting_for).once.with("dick").and_return(@turn).ordered(:turns)
    @scorekeeper.should_receive(:turn_is_ending_for).once.with("dick", @turn).ordered(:turns)
    @scorekeeper.should_receive(:turn_is_starting_for).once.with("harry").and_return(@turn).ordered(:turns)
    @scorekeeper.should_receive(:turn_is_ending_for).once.with("harry", @turn).ordered(:turns)
    @scorekeeper.should_ignore_missing
    @io_device.should_ignore_missing

    @game.play()
  end

  it "should output score summary on game completion" do
    @scorekeeper.should_receive(:player_has_winning_score?).and_return("tom")
    @scorekeeper.should_receive(:turn_is_starting_for).zero_or_more_times.and_return(@turn)
    @scorekeeper.should_ignore_missing
    @scorekeeper.should_receive(:score_summary).once.and_return("fake summary")
    @io_device.should_receive(:write_output).once.with(/tom has scored greater than 3000/)
    @io_device.should_receive(:write_output).once.with(/fake summary/)

    @game.play()
  end
end

describe GreedGameTurn, "when first created" do
  it "should raise ArgumentError if player is nil or not kind_of? Player" do
    lambda { GreedGameTurn.new nil, flexmock(:kind_of? => :ScoreKeeper), flexmock(:kind_of? => :DiceSet) }.should raise_error(ArgumentError, /player can not be nil/)
    lambda { GreedGameTurn.new Object.new, flexmock(:kind_of? => :ScoreKeeper), flexmock(:kind_of? => :DiceSet) }.should raise_error(ArgumentError, /player can not be nil/)
  end

  it "should raise ArgumentError if scorekeeper is nil or not kind_of? ScoreKeeper" do
    lambda { GreedGameTurn.new flexmock(:kind_of? => :Player), nil, flexmock(DiceSet) }.should raise_error(ArgumentError, /scorekeeper can not be nil/)
    lambda { GreedGameTurn.new flexmock(:kind_of? => :Player), Object.new, flexmock(DiceSet) }.should raise_error(ArgumentError, /scorekeeper can not be nil/)
  end

  it "should raise ArgumentError if dice are nil or not kind_of? DiceSet" do
    lambda { GreedGameTurn.new flexmock(:kind_of? => :Player), flexmock(:kind_of? => :ScoreKeeper), nil }.should raise_error(ArgumentError, /dice can not be nil/)
    lambda { GreedGameTurn.new flexmock(:kind_of? => :Player), flexmock(:kind_of? => :ScoreKeeper), Object.new }.should raise_error(ArgumentError, /dice can not be nil/)
  end

  it "should have zero score" do
    turn = GreedGameTurn.new flexmock(:kind_of? => :Player), flexmock(:kind_of? => :ScoreKeeper), flexmock(:kind_of? => :DiceSet)
    turn.score.should eql(0)
  end
end

describe GreedGameTurn, "when turn is being played" do
  before( :each ) do
    @io_device = flexmock("fake io device")
    @scorekeeper = flexmock("fake scorekeeper", :kind_of? => :ScoreKeeper)    
    @turn = GreedGameTurn.new(Player.new("tom"), @scorekeeper, DiceSet.new())
  end

  it "should display player info" do
    @io_device.should_receive(:write_output).with(/tom's turn!/).once.ordered(:outputs)
    @io_device.should_receive(:write_output).with_any_args.ordered(:outputs)
    @io_device.should_receive(:get_input).returns("")
    @turn.play(@io_device)
  end

  it "should prompt player to roll dice" do
    @io_device.should_receive(:write_output)
    @io_device.should_receive(:write_output).with(/"Roll dice?/).ordered(:outputs)
    @io_device.should_receive(:get_input).returns("")
    @turn.play(@io_device)
  end

  it "should finish when all dice are scoring dice" do
    @io_device.should_receive(:write_output, :get_input).with_any_args.zero_or_more_times.and_return("y")
    @scorekeeper.should_receive(:score_roll).once.with_any_args.and_return([500,0])
    @turn.play(@io_device)
  end

  it "should finish when player chooses not to roll more dice" do
    @io_device.should_receive(:write_output)
    @io_device.should_receive(:get_input).twice.and_return("y", "n")
    @scorekeeper.should_receive(:score_roll).once.with_any_args.and_return([500,2])
    @turn.play(@io_device)
  end

  it "should have score equal to sum of scores from all rolls during turn" do
  @io_device.should_receive(:write_output, :get_input).with_any_args.zero_or_more_times.and_return("y")
    @scorekeeper.should_receive(:score_roll).times(3).with_any_args.and_return([500,2], [250,1], [250,0])
    @turn.play(@io_device)
    @turn.score.should eql(1000)
  end

  it "should finish when player rolls a dice score of zero and score for entire turn should be zero" do
    @io_device.should_receive(:write_output, :get_input).with_any_args.zero_or_more_times.and_return("y")
    @scorekeeper.should_receive(:score_roll).once.with_any_args.and_return([0,5])
    @turn.play(@io_device)
    @turn.score.should eql(0)
  end

end

describe Player, "when first created" do
  before(:each) do
    @player = Player.new "SomePlayer"
  end

  it "should have name" do
    @player.name.should eql("SomePlayer")
  end

  it "should have zero score" do
    @player.score.should eql(0)
  end

  it "should not be in game" do
    @player.in_game.should be_false
  end
end

describe Player, "when updating score" do
  before(:each) do
    @player = Player.new "SomePlayer"
  end

  it "should become in game if score 300 or greater points" do
    points = rand(700) + 300
    @player.update_score(points)
    @player.in_game.should be_true
  end

  it "should update score if in game" do
    @player.update_score(300)
    points = rand(700)
    @player.update_score(points)
    @player.score.should eql(300 + points)
  end

end

describe DiceSet, "when first created" do
  it "should be created" do
    @dice = DiceSet.new
    @dice.should_not be_nil
  end
end

describe DiceSet, "when rolling dice" do
  before(:each) do
    @dice = DiceSet.new
  end

  it "should return a set of integers between 1 and 6" do
    @dice.roll(5)
    @dice.values.should be_a(Array)
    @dice.values.should have(5).items
    @dice.values.each do |value|
      true.should eql(value >=1 && value <=6)
    end
  end

  it "should not change values unless rolled" do
    @dice.roll(5)
    first_time = @dice.values
    second_time = @dice.values
    first_time.should eql(second_time)
  end

  it "should change values when dice are rolled"  do
    @dice.roll(5)
    first_time = @dice.values

    @dice.roll(5)
    second_time = @dice.values

    first_time.should_not eql(second_time)
  end

  it "should allow for rolling different numbers of dice" do
    @dice.roll(3)
    @dice.values.should have(3).items

    @dice.roll(1)
    @dice.values.should have(1).items
  end
end

describe ScoreKeeper, "when first created" do
  it "should have zero players" do
    scorekeeper = ScoreKeeper.new
    scorekeeper.players.should have(0).players
  end
end

describe ScoreKeeper, "when adding players" do
  it "should add the players in order" do
    scorekeeper = ScoreKeeper.new
    scorekeeper.add_player "tom"
    scorekeeper.add_player "dick"
    scorekeeper.add_player "harry"

    scorekeeper.players.should have(3).players
    scorekeeper.players.should eql(["tom", "dick", "harry"])
  end
end

describe ScoreKeeper, "when player is starting a turn" do
  before( :each ) do
    @scorekeeper = ScoreKeeper.new
    @scorekeeper.add_player "tom"
  end

  it "should raise ArgumentError if player was not previously added" do
    lambda { @scorekeeper.turn_is_starting_for("dick") }.should raise_error(ArgumentError, /No player/)
  end

  it "should create a new turn for a previously added player" do
    flexmock(GreedGameTurn).
            new_instances.should_receive(:new).
            with(FlexMock.on {|arg| arg.kind_of?(Player) && arg.name == "tom"} ).
            with(@scorekeeper).
            with(DiceSet)
    turn = @scorekeeper.turn_is_starting_for("tom")
  end
end

describe ScoreKeeper, "when player is ending a turn" do
  before( :each ) do
    @scorekeeper = ScoreKeeper.new
    @scorekeeper.add_player "tom"
  end

  it "should raise ArgumentError if player was not previously added" do
    lambda { @scorekeeper.turn_is_ending_for("dick", flexmock("faketurn")) }.should raise_error(ArgumentError, /No player/)
  end

  it "should update the player's score" do
    turn = flexmock("faketurn", :score=>400)
    @scorekeeper.turn_is_ending_for("tom", turn)
    @scorekeeper.score_for_player?("tom").should eql(400)
  end
end

describe ScoreKeeper, "when checking if a player has a winning score" do
  before( :each ) do
    @scorekeeper = ScoreKeeper.new
    @scorekeeper.add_player "tom"
  end

  it "should return nil if no player has a score >= 3000" do
    @scorekeeper.player_has_winning_score?.should be_nil    
  end

  it "should return name of player with score >= 3000" do
    turn = flexmock("faketurn", :score=>3001)
    @scorekeeper.turn_is_ending_for("tom", turn)
    @scorekeeper.player_has_winning_score?.should eql("tom")
  end
end

describe ScoreKeeper, "when getting a score summary" do
  it "should print score for every player and indicate winning player" do
    scorekeeper = ScoreKeeper.new
    scorekeeper.add_player "tom"
    scorekeeper.add_player "dick"
    scorekeeper.add_player "harry"

    turn = flexmock("faketurn", :score=>3001)
    scorekeeper.turn_is_ending_for("tom", turn)
    score_summary = scorekeeper.score_summary

    score_summary.should match(/tom scored: 3001 points. -- WINNER!/)
    score_summary.should match(/dick scored: 0 points./)
    score_summary.should match(/harry scored: 0 points./)    
  end
end

describe ScoreKeeper, "when scoring a roll of the dice" do
  before( :each ) do
    @scorekeeper = ScoreKeeper.new
    @scorekeeper.add_player "tom"
  end

  it "should have zero score and zero non-scoring dice for empty roll" do
    score_result = @scorekeeper.score_roll([])
    score_result.should eql([0,0])
  end

  it "should have a score of 50 and zero non-scoring dice for a roll of a single 5" do
    score_result = @scorekeeper.score_roll([5])
    score_result.should eql([50,0])
  end

  it "should have a score of 100 and zero non-scoring dice for a roll of a single 1" do
    score_result = @scorekeeper.score_roll([1])
    score_result.should eql([100,0])    
  end

  it "should have a score of the sum of 1*n*100 + 5*n*50 and zero non-scoring dice for a roll of 1s and 5s" do
    score_result = @scorekeeper.score_roll([1,5,5,1])
    score_result.should eql([300,0])
  end

  it "should have a score of zero and four non-scoring dice for a roll of 2s,3s,4s, and 6s" do
    score_result = @scorekeeper.score_roll([2,4,4,6])
    score_result.should eql([0,4])
  end

  it "should have a score of 1000 and zero non-scoring dice for a roll of triple 1s" do
    score_result = @scorekeeper.score_roll([1,1,1])
    score_result.should eql([1000,0])
  end

  it "should have a score of 100*digit and zero non-scoring dice for a roll of triple 2s, 3s, 4s, 5s, and 6s" do
    score_result = @scorekeeper.score_roll([2,2,2])
    score_result.should eql([200,0])
    score_result = @scorekeeper.score_roll([3,3,3])
    score_result.should eql([300,0])
    score_result = @scorekeeper.score_roll([4,4,4])
    score_result.should eql([400,0])
    score_result = @scorekeeper.score_roll([5,5,5])
    score_result.should eql([500,0])
    score_result = @scorekeeper.score_roll([6,6,6])
    score_result.should eql([600,0])
  end

  it "should have a score of the mixed sum and zero non-scoring dice for a roll of all scoring dice" do
    score_result = @scorekeeper.score_roll([2,2,2,5,5])
    score_result.should eql([300,0])
    score_result = @scorekeeper.score_roll([5,5,5,5])
    score_result.should eql([550,0])
  end

  it "should have a score of the mixed sum and N non-scoring dice for a roll with N non-scoring dice" do
    score_result = @scorekeeper.score_roll([2,3,4,5,5])
    score_result.should eql([100,3])
    score_result = @scorekeeper.score_roll([5,5,5,6,4])
    score_result.should eql([500,2])
  end
 
end

