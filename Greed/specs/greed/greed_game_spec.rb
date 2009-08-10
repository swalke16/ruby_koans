require File.dirname(__FILE__) + "/../spec_helper"

describe GreedGame, "when first created" do
  it "should be created" do
    game = GreedGame.new
    game.should_not be_nil
  end
end

describe GreedGame, "when playing the game with no ui" do
  it "should raise argument error" do
    game = GreedGame.new

    lambda { game.play(nil, nil) }.should raise_error(ArgumentError, /game_ui can not be nil/)
  end
end

describe GreedGame, "when playing the game with less than two players" do
  it "should raise an argument error" do
    game = GreedGame.new
    game_ui = flexmock("fake game ui")

    lambda { game.play(game_ui, nil) }.should raise_error(ArgumentError, /Two or more players/)
    lambda { game.play(game_ui, []) }.should raise_error(ArgumentError, /Two or more players/)
  end
end

describe GreedGame, "when playing rounds 1...N of the game with three players tom, dick, and harry"  do
  before(:each) do
    @game_ui = flexmock("fake game ui")
    @game_ui.should_ignore_missing

    @tom = flexmock("player tom")
    @tom.should_receive(:score).and_return(0, 0, 0, 0, 3175)
    @dick = flexmock("player dick")
    @dick.should_receive(:score).and_return(0)
    @harry = flexmock("player harry")
    @harry.should_receive(:score).and_return(0)

    @players = [@tom, @dick, @harry]
    @game = GreedGame.new
  end

  it "should give every player a turn to roll until a player has a winning score (>= 3000)" do
    @tom.should_receive(:play_turn).once.with(DiceSet, @game_ui).ordered(:turns)
    @dick.should_receive(:play_turn).twice.with(DiceSet, @game_ui).ordered(:turns)
    @harry.should_receive(:play_turn).twice.with(DiceSet, @game_ui).ordered(:turns)

    @game.play(@game_ui, @players)
  end
end

describe GreedGame, "when playing the final round of the game with three players tom, dick, and harry" do
  before(:each) do
    @game_ui = flexmock("fake game ui")
    @game_ui.should_ignore_missing

    @tom = flexmock("player tom")
    @tom.should_receive(:score).and_return(3175)
    @tom.should_receive(:play_turn).never
    @dick = flexmock("player dick")
    @dick.should_receive(:score).and_return(0)
    @dick.should_receive(:play_turn).once.with(DiceSet, @game_ui).ordered(:turns)
    @harry = flexmock("player harry")
    @harry.should_receive(:score).and_return(0)
    @harry.should_receive(:play_turn).once.with(DiceSet, @game_ui).ordered(:turns)

    @players = [@tom, @dick, @harry]
    @game = GreedGame.new
  end

  it "should give every player other than the leading player one more turn once a player has a winning score (>= 3000)" do
    @game.play(@game_ui, @players)
  end

  it "should not raise error when game ui does not respond to :entering_final_round" do
    lambda {@game.play(@game_ui, @players)}.should_not raise_error(ArgumentError)
  end

  it "should notify game ui about :entering_final_round with leading player"  do
    @game_ui.should_receive(:entering_final_round).with(@tom)

    @game.play(@game_ui, @players)
  end
end