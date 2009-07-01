require "spec"
require "../greed_game"

Spec::Runner.configure do |config|
  config.mock_with :flexmock
end

describe GreedGame, "When first created" do

  # Called before each example.
  before(:each) do
  end

  # Called after each example.
  after(:each) do
  end

  it "should have zero players" do
    sut = GreedGame.new flexmock(:get_input=>"", :write_output=>"")
    sut.players.should eql(0)
  end
end