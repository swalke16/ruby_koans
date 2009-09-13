require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe GreedGameConsoleUI do
  context "when first created" do
    it "is created" do
      game_ui = GreedGameConsoleUI.new( flexmock("fake game engine") )
      game_ui.should_not be_nil
    end

    it "raises ArgumentError if greed_game_engine is nil" do
      lambda { GreedGameConsoleUI.new(nil)}.should raise_error(ArgumentError, /nil/)
    end
  end
  
  context "when playing" do
    before(:each) do            
      @terminal = flexmock("fake terminal") 

      @terminal.should_receive(:ask).times(4).with(/Enter player/).and_return("tom", "dick", "harry", "")
      flexmock(HighLine).should_receive(:new).and_return(@terminal)

      @game_engine = flexmock("fake game engine")
      @game_ui = GreedGameConsoleUI.new(@game_engine)
    end

    it "prompts for player names until no names entered" do
      @game_engine.should_ignore_missing
      @terminal.should_ignore_missing

      @game_ui.play()
    end

    it "plays the game with the players that were entered"  do
      @game_engine.should_ignore_missing
      @terminal.should_ignore_missing
      @game_engine.
        should_receive(:play).
        with(@game_ui, FlexMock.on {|arg| arg[0].name == "tom" && arg[1].name == "dick" && arg[2].name == "harry" })

      @game_ui.play()
    end

    it "writes ArgumentErrors from the game engine to the console" do
      @game_engine.should_receive(:play).and_raise(ArgumentError, "fake argument error")
      @terminal.should_receive(:say).at_least.once.with(/fake argument error/)
      @terminal.should_receive(:say)

      @game_ui.play()
    end
  
    it "prints score for every player and indicate winning player" do
      tom = flexmock("player tom", :name=>"tom", :score=>3001)
      dick = flexmock("player tom", :name=>"dick", :score=>0)
      harry = flexmock("player tom", :name=>"harry", :score=>0)        
      @game_engine.should_ignore_missing
      @game_engine.should_receive(:players).and_return([tom, dick, harry])
      
      @terminal.should_receive(:say).at_least.once.with(/tom.*3001.*WINNER.*dick.*0.*harry.*0/m)
      @terminal.should_receive(:say)

      @game_ui.play()    
    end
  end

  context "when a turn is ending for a player named tom" do
    before(:each) do
      @terminal = flexmock("fake terminal") 
      flexmock(HighLine).should_receive(:new).and_return(@terminal)

      @game_engine = flexmock("fake game engine")
      @game_ui = GreedGameConsoleUI.new(@game_engine)
    end

    it "displays the status of the turn if the turn was a scoring turn" do
      turn = flexmock("fake turn")
      turn.should_receive("was_lost").and_return(false)
      turn.should_receive("score").and_return(500)
    
      @terminal.should_receive(:say).with(/Your turn has now ended! You scored a total of.*500/)
      @terminal.should_receive(:say)
    
      @game_ui.turn_ending(turn)
    end
  
    it "displays the lost turn message if the turn was lost" do
      turn = flexmock("fake turn")
      turn.should_receive("was_lost").and_return(true)
    
      @terminal.should_receive(:say).with(/You rolled a zero so you lost your turn and any accumulated score for this turn./)
      @terminal.should_receive(:say)
    
      @game_ui.turn_ending(turn)
    end  
  end

  context "when asking if a player wants to roll again" do
    before(:each) do
      @terminal = flexmock("fake terminal") 
      flexmock(HighLine).should_receive(:new).and_return(@terminal)

      @turn = flexmock("fake turn")
      @turn.should_receive("dice_left_to_roll").and_return(3)
      @turn.should_ignore_missing

      @game_engine = flexmock("fake game engine")
      @game_ui = GreedGameConsoleUI.new(@game_engine)
    end

    it "asks player if they want to roll again, returning true if the player typed a 'y'" do
      @terminal.should_receive(:agree).with(/You have.*3.*dice left to roll. Roll dice?/, true, Proc).and_return(true)
    
      roll_again = @game_ui.player_wants_to_roll_again?(@turn)    
    
      roll_again.should eql(true)
    end

    it "asks player if they want to roll again, returning false if the player typed a 'n'" do
      @terminal.should_receive(:agree).with(/You have.*3.*dice left to roll. Roll dice?/, true, Proc).and_return(false)
    
      roll_again = @game_ui.player_wants_to_roll_again?(@turn)    
    
      roll_again.should eql(false)
    end
  end
end

