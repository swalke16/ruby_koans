require File.dirname(__FILE__) + "/../spec_helper"

describe Player do 
  context "when first created" do
    before(:each) do
      @player = Player.new "SomePlayer"
    end

    it "has a name" do
      @player.name.should eql("SomePlayer")
    end

    it "has a zero score" do
      @player.score.should eql(0)
    end

    it "is not in the game" do
      @player.in_game.should be_false
    end
  end

  context "when playing a turn" do
    before(:each) do
      @player = Player.new("SomePlayer")
      @game_ui = flexmock("fake game_ui")
      @dice = flexmock("fake dice")
    end

    it "raises ArgumentError if dice is nil" do
      lambda { @player.play_turn(nil, flexmock("fake game ui")) }.should raise_error(ArgumentError, /dice can not be nil/)
    end

    it "raises ArgumentError if game ui is nil" do
      lambda { @player.play_turn(flexmock("fake dice"), nil) }.should raise_error(ArgumentError, /game_ui can not be nil/)
    end

    it "plays a turn" do
      flexmock(GreedGameTurn).new_instances do |m|
        m.should_receive(:new)
          with(@player).
          with(@game_ui)

        m.should_receive(:play).
          with(@dice)
      end
    end

    it "becomes in game if turn score is 300 points or greater" do
      flexmock(GreedGameTurn).new_instances do |m|
        m.should_receive(:new).with(@player).with(@game_ui)
        m.should_receive(:play).with(@dice)
        m.should_receive(:was_lost).and_return(false)
        m.should_receive(:score).and_return(rand(700) + 300)
      end

      @player.in_game.should eql(false)

      @player.play_turn(@dice, @game_ui)

      @player.in_game.should eql(true)
    end

    it "turn score gets added to current score if in game" do
      flexmock(GreedGameTurn).new_instances do |m|
        m.should_receive(:new).with(@player).with(@game_ui)
        m.should_receive(:play).with(@dice)
        m.should_receive(:was_lost).and_return(false)
        m.should_receive(:score).and_return(300)
      end

      @player.play_turn(@dice, @game_ui)
      @player.play_turn(@dice, @game_ui)

      @player.score.should eql(600)
    end
  end
end