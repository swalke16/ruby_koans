require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe GreedGameTurn do
  context "when first created" do
    it "raises ArgumentError if player is nil" do
      lambda { GreedGameTurn.new nil, flexmock("fake game ui") }.should raise_error(ArgumentError, /player can not be nil/)
    end

    it "raises ArgumentError if game ui is nil" do
      lambda { GreedGameTurn.new flexmock("fake player"), nil}.should raise_error(ArgumentError, /game_ui can not be nil/)
    end

    it "has zero score" do
      turn = GreedGameTurn.new flexmock("fake player"), flexmock("fake game ui")
      turn.score.should eql(0)
    end

    it "is not a lost turn" do
      turn = GreedGameTurn.new flexmock("fake player"), flexmock("fake game ui")
      turn.was_lost.should eql(false)
    end

    it "is for the player specified during creation" do
      fake_player = flexmock("fake player")
      turn = GreedGameTurn.new fake_player, flexmock("fake game ui")
      turn.player.should eql(fake_player)
    end

    it "has 5 dice left to roll" do
      turn = GreedGameTurn.new flexmock("fake player"), flexmock("fake game ui")
      turn.dice_left_to_roll.should eql(5)     
    end
  end

  context "when turn is being played" do
    before( :each ) do
      @game_ui = flexmock("fake game ui")
      @game_ui.should_receive(:player_wants_to_roll_again?).zero_or_more_times.with_any_args.and_return(false).by_default
      @game_ui.should_ignore_missing
      @player = flexmock("fake player")
      @player.should_ignore_missing
      @dice = flexmock("fake dice")
      @dice.should_ignore_missing
      @turn = GreedGameTurn.new(@player, @game_ui)
    end

    it "raises ArgumentError if dice are nil" do
      lambda { @turn.play(nil)  }.should raise_error(ArgumentError, /dice can not be nil/)
    end

    it "notifies game ui about :turn_starting"  do
      @game_ui.should_receive(:turn_starting).with(@turn)

      @turn.play(@dice)
    end

    it "does not raise error when game ui does not respond to :turn_starting" do
      @turn.play(@dice)

      lambda {@turn.play(@dice)}.should_not raise_error(ArgumentError)
    end

    it "noties game ui about :turn_ending"  do
      @game_ui.should_receive(:turn_ending).with(@turn)

      @turn.play(@dice)
    end

    it "does not raise error when game ui does not respond to :turn_ending" do
      @turn.play(@dice)

      lambda {@turn.play(@dice)}.should_not raise_error(ArgumentError)
    end

    it "asks the game ui if the player wants to roll again" do
      @game_ui.should_receive(:player_wants_to_roll_again?).with(@turn).and_return(false)

      @turn.play(@dice)
    end

    it "raises error when game ui does not respond to :player_wants_to_roll_again?" do
      @turn = GreedGameTurn.new(@player, flexmock("fake game ui"))

      lambda {@turn.play(@dice)}.should raise_error(ArgumentError, /must respond to :player_wants_to_roll_again/)
    end

    it "finishes when all dice are scoring dice" do
      @game_ui.should_receive(:player_wants_to_roll_again?).with_any_args.zero_or_more_times.and_return(true)
      @dice.should_receive(:number_of_non_scoring).and_return(0)

      @turn.play(@dice)
    end

    it "finishes when player chooses not to roll more dice" do
      @game_ui.should_receive(:player_wants_to_roll_again?).with_any_args.and_return(false)

      @turn.play(@dice)
    end

    it "score equals sum of scores from all rolls during turn" do
      @game_ui.should_receive(:player_wants_to_roll_again?).with_any_args.zero_or_more_times.and_return(true)
      @dice.should_receive(:number_of_non_scoring).times(3).and_return(2,1,0)
      @dice.should_receive(:score).and_return(250)

      @turn.play(@dice)

      @turn.score.should eql(750)
    end

    it "finishes when player rolls a dice score of zero and score for entire turn should be zero" do
      @game_ui.should_receive(:player_wants_to_roll_again?).with_any_args.zero_or_more_times.and_return(true)
      @dice.should_receive(:score).and_return(0)

      @turn.play(@dice)

      @turn.score.should eql(0)
      @turn.was_lost.should eql(true)
    end
  end
end