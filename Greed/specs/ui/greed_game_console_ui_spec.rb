require File.dirname(__FILE__) + "/../spec_helper"

#TODO: missing tests for handling game output / input
#TODO: missing tests for game summary
#TODO: fix failing test

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

    @game_engine = flexmock("fake game engine", :input_request_handler= => nil)
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
    @game_engine.
      should_receive(:play).
      with(on {|arg| arg[0].name == "tom" && arg[1].name == "dick" && arg[3].name == "harry" })

    @game_ui.play()
  end

  it "should write ArgumentErrors from the game engine to the console" do
    @game_engine.should_receive(:play).and_raise(ArgumentError, "fake argument error")

    @game_ui.play()

    @output.string.should match(/fake argument error/)
  end
end