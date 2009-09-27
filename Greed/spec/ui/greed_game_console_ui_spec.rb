require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe GreedGameConsoleUI do
  context "when first created" do
    it "is created" do
      game_ui = GreedGameConsoleUI.new( flexmock("fake game engine") )
      game_ui.should_not be_nil
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
end


