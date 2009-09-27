require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe GreedGameTurn do
  context "when first created" do
    before(:each) do
      @dice = flexmock("fake dice")
      @turn = GreedGameTurn.new(@dice)
    end
    
    it "has zero score" do
      @turn.score.should eql(0)
    end

    it "is not a lost turn" do
      @turn.was_lost.should eql(false)
    end

    it "has 5 dice left to roll" do
      @turn.dice_left_to_roll.should eql(5)     
    end
  end

  context "when turn is being played" do
    before( :each ) do
      @player = flexmock("fake player")
      @dice = flexmock("fake dice")
      @dice.should_ignore_missing
      @turn = GreedGameTurn.new(@dice)
    end

    it "finishes when all dice are scoring dice" do
      @player.should_receive(:wants_to_roll_again?).with(@turn).zero_or_more_times.and_return(true)
      @dice.should_receive(:number_of_non_scoring).and_return(0)

      @turn.play(@player)
    end

    it "finishes when player chooses not to roll more dice" do
      @player.should_receive(:wants_to_roll_again?).with(@turn).and_return(false)

      @turn.play(@player)
    end

    it "score equals sum of scores from all rolls during turn" do
      @player.should_receive(:wants_to_roll_again?).with(@turn).zero_or_more_times.and_return(true)
      @dice.should_receive(:number_of_non_scoring).times(3).and_return(2,1,0)
      @dice.should_receive(:score).and_return(250)

      @turn.play(@player)

      @turn.score.should eql(750)
    end

    it "finishes when player rolls a dice score of zero and score for entire turn should be zero" do
      @player.should_receive(:wants_to_roll_again?).with(@turn).zero_or_more_times.and_return(true)
      @dice.should_receive(:score).and_return(0)

      @turn.play(@player)

      @turn.score.should eql(0)
      @turn.was_lost.should eql(true)
    end
  end
end