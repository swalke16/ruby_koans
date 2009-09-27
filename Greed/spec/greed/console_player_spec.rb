require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe ConsolePlayer do 
  context "when first created" do
    before(:each) do
      @player = ConsolePlayer.new("SomePlayer", flexmock("fake terminal"))
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
      @terminal = flexmock("fake terminal")
      @player = ConsolePlayer.new("SomePlayer", @terminal)
      @turn = flexmock("fake turn") do |m|
        m.should_receive(:play).with(@player)
      end
    end

    it "becomes in game if turn score is 300 points or greater" do
      @terminal.should_ignore_missing
      @turn.should_receive(:was_lost).and_return(false)
      @turn.should_receive(:score).and_return(rand(700) + 300)
            
      @player.in_game.should eql(false)

      @player.play_turn(@turn)

      @player.in_game.should eql(true)
    end

    it "turn score gets added to current score if in game" do
      @terminal.should_ignore_missing
      @turn.should_receive(:was_lost).and_return(false)
      @turn.should_receive(:score).and_return(300)

      @player.play_turn(@turn)
      @player.play_turn(@turn)

      @player.score.should eql(600)
    end

#TODO: Displays turn starting message...

    it "displays the status of the turn if the turn was a scoring turn" do
      @turn.should_receive(:score).and_return(500)
      @turn.should_receive(:was_lost).and_return(false)
    
      @terminal.should_receive(:say).with(/Your turn has now ended! You scored a total of.*500/)
      @terminal.should_receive(:say)
    
      @player.play_turn(@turn)
    end
  
    it "displays the lost turn message if the turn was lost" do
      @turn.should_receive(:was_lost).and_return(true)
    
      @terminal.should_receive(:say).with(/You rolled a zero so you lost your turn and any accumulated score for this turn./)
      @terminal.should_receive(:say)
    
      @player.play_turn(@turn)
    end

  end
  
  context "when asking if a player wants to roll again" do
    before(:each) do
      @terminal = flexmock("fake terminal")
      @player = ConsolePlayer.new("SomePlayer", @terminal)
      @turn = flexmock("fake turn") do |m|
        m.should_receive(:play).with(@player)
        m.should_receive("dice_left_to_roll").and_return(3)
        m.should_ignore_missing
      end
    end

    it "asks player if they want to roll again, returning true if the player typed a 'y'" do
      @terminal.should_receive(:agree).with(/You have.*3.*dice left to roll. Roll dice?/, true, Proc).and_return(true)
    
      roll_again = @player.wants_to_roll_again?(@turn)    
    
      roll_again.should eql(true)
    end

    it "asks player if they want to roll again, returning false if the player typed a 'n'" do
      @terminal.should_receive(:agree).with(/You have.*3.*dice left to roll. Roll dice?/, true, Proc).and_return(false)
    
      roll_again = @player.wants_to_roll_again?(@turn)    
    
      roll_again.should eql(false)
    end
  end
end