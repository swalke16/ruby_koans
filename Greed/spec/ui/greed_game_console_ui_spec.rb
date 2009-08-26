require File.dirname(__FILE__) + "/../spec_helper"

describe GreedGameConsoleUI, "when first created" do
  it "should be created" do
    game_ui = GreedGameConsoleUI.new( flexmock("fake game engine", :input_request_handler= => nil) )
    game_ui.should_not be_nil
  end

  it "should raise ArgumentError if greed_game_engine is nil" do
    lambda { GreedGameConsoleUI.new(nil)}.should raise_error(ArgumentError, /nil/)
  end
end

describe GreedGameConsoleUI, "when playing" do

  before(:each) do
    @players = ["tom", "dick", "harry"]
    @output = StringIO.new
    @input = StringIO.new(@players.join("\n"), "r")

    $stdout = @output
    $stdin = @input

    @game_engine = flexmock("fake game engine")
    @game_ui = GreedGameConsoleUI.new(@game_engine)
  end

  it "should prompt for player names until no names entered" do
    @game_engine.should_ignore_missing

    @game_ui.play()

    @players.each_index do |idx|
       @output.string.should match(%{Enter player #{idx + 1} name: })
    end
  end

  it "should play the game with the players that were entered"  do
    @game_engine.should_ignore_missing
    @game_engine.
      should_receive(:play).
      with(@game_ui, FlexMock.on {|arg| arg[0].name == "tom" && arg[1].name == "dick" && arg[2].name == "harry" })

    @game_ui.play()
  end

  it "should write ArgumentErrors from the game engine to the console" do
    @game_engine.should_receive(:play).and_raise(ArgumentError, "fake argument error")

    @game_ui.play()

    @output.string.should match(/fake argument error/)
  end
  
  it "should print score for every player and indicate winning player" do
    tom = flexmock("player tom", :name=>"tom", :score=>3001)
    dick = flexmock("player tom", :name=>"dick", :score=>0)
    harry = flexmock("player tom", :name=>"harry", :score=>0)        
    @game_engine.should_ignore_missing
    @game_engine.should_receive(:players).and_return([tom, dick, harry])

    @game_ui.play()

    @output.string.should match(/tom scored: 3001 points. -- WINNER!/)
    @output.string.should match(/dick scored: 0 points./)
    @output.string.should match(/harry scored: 0 points./)    
  end
end

describe GreedGameConsoleUI, "when a turn is starting for a player named tom" do
  before(:each) do
    @output = StringIO.new
    $stdout = @output

    @game_engine = flexmock("fake game engine")
    @game_ui = GreedGameConsoleUI.new(@game_engine)
  end
  
  it "should display the status of the turn" do
    turn = flexmock("fake turn")
    turn.should_receive("player.name").and_return("tom")
    turn.should_receive("player.in_game").and_return(true)
    turn.should_receive("player.score").and_return(3001)
    turn.should_receive("score").and_return(500)
    
    @game_ui.turn_starting(turn)
    
    @output.string.should match(/tom's turn! In Game: true Game Score: 3001 Turn Score: 500/)
  end
end

describe GreedGameConsoleUI, "when a turn is ending for a player named tom" do
  before(:each) do
    @output = StringIO.new

    $stdout = @output

    @game_engine = flexmock("fake game engine")
    @game_ui = GreedGameConsoleUI.new(@game_engine)
  end
  
  it "should display the status of the turn if the turn was a scoring turn" do
    turn = flexmock("fake turn")
    turn.should_receive("was_lost").and_return(false)
    turn.should_receive("score").and_return(500)
    
    @game_ui.turn_ending(turn)
    
    @output.string.should match(/Your turn has now ended! You scored a total of 500 points for this turn!/)
  end
  
  it "should display the lost turn message if the turn was lost" do
    turn = flexmock("fake turn")
    turn.should_receive("was_lost").and_return(true)
    
    @game_ui.turn_ending(turn)
    
    @output.string.should match(/You rolled a zero so you lost your turn and any accumulated score for this turn./)    
  end  
end

describe GreedGameConsoleUI, "when asking if a player wants to roll again" do
  before(:each) do
    @output = StringIO.new
    $stdout = @output

    @game_engine = flexmock("fake game engine")
    @game_ui = GreedGameConsoleUI.new(@game_engine)
  end

  it "should ask player if they want to roll again, returning true if the player typed a 'y'" do
    turn = flexmock("fake turn")
    turn.should_receive("dice_left_to_roll").and_return(3)
    input = StringIO.new("y")
    $stdin = input
    
    roll_again = @game_ui.player_wants_to_roll_again?(turn)    
    
    @output.string.should match(/You have 3 dice left to roll. Roll dice?/)
    roll_again.should eql(true)
  end

  it "should ask player if they want to roll again, returning false if the player typed a 'n'" do
    turn = flexmock("fake turn")
    turn.should_receive("dice_left_to_roll").and_return(3)
    input = StringIO.new("n")
    $stdin = input
    
    roll_again = @game_ui.player_wants_to_roll_again?(turn)    
    
    @output.string.should match(/You have 3 dice left to roll. Roll dice?/)
    roll_again.should eql(false)
  end


end