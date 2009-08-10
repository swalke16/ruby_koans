require File.dirname(__FILE__) + "/../spec_helper"

describe DiceSet, "when first created" do
  it "should be created" do
    @dice = DiceSet.new
    @dice.should_not be_nil
  end
end

describe DiceSet, "when rolling dice" do
  before(:each) do
    @dice = DiceSet.new
  end

  it "values should be a set of integers between 1 and 6 when passed a number" do
    @dice.roll(5)
    @dice.values.should be_a(Array)
    @dice.values.should have(5).items
    @dice.values.each do |value|
      true.should eql(value >=1 && value <=6)
    end
  end

  it "values should be the set of numbers when passed an enumerable" do
    @dice.roll([1,2,3])

    @dice.values.should eql([1,2,3])
  end

  it "should not change values unless rolled" do
    @dice.roll(5)
    first_time = @dice.values
    second_time = @dice.values
    first_time.should eql(second_time)
  end

  it "should change values when dice are rolled"  do
    @dice.roll(5)
    first_time = @dice.values

    @dice.roll(5)
    second_time = @dice.values

    first_time.should_not eql(second_time)
  end

  it "should allow for rolling different numbers of dice" do
    @dice.roll(3)
    @dice.values.should have(3).items

    @dice.roll(1)
    @dice.values.should have(1).items
  end

  it "should have zero score and zero non-scoring dice for empty roll" do
    @dice.roll([])
    @dice.score.should eql(0)
    @dice.number_of_non_scoring.should eql(0)
  end

  it "should have a score of 50 and zero non-scoring dice for a roll of a single 5" do
    @dice.roll([5])
    @dice.score.should eql(50)
    @dice.number_of_non_scoring.should eql(0)
  end

  it "should have a score of 100 and zero non-scoring dice for a roll of a single 1" do
    @dice.roll([1])
    @dice.score.should eql(100)
    @dice.number_of_non_scoring.should eql(0)
  end

  it "should have a score of the sum of 1*n*100 + 5*n*50 and zero non-scoring dice for a roll of 1s and 5s" do
    @dice.roll([1,5,5,1])
    @dice.score.should eql(300)
    @dice.number_of_non_scoring.should eql(0)
  end

  it "should have a score of zero and four non-scoring dice for a roll of 2s,3s,4s, and 6s" do
    @dice.roll([2,4,4,6])
    @dice.score.should eql(0)
    @dice.number_of_non_scoring.should eql(4)
  end

  it "should have a score of 1000 and zero non-scoring dice for a roll of triple 1s" do
    @dice.roll([1,1,1])
    @dice.score.should eql(1000)
    @dice.number_of_non_scoring.should eql(0)
  end

  it "should have a score of 100*digit and zero non-scoring dice for a roll of triple 2s, 3s, 4s, 5s, and 6s" do
    @dice.roll([2,2,2])
    @dice.score.should eql(200)
    @dice.number_of_non_scoring.should eql(0)
    @dice.roll([3,3,3])
    @dice.score.should eql(300)
    @dice.number_of_non_scoring.should eql(0)
    @dice.roll([4,4,4])
    @dice.score.should eql(400)
    @dice.number_of_non_scoring.should eql(0)
    @dice.roll([5,5,5])
    @dice.score.should eql(500)
    @dice.number_of_non_scoring.should eql(0)
    @dice.roll([6,6,6])
    @dice.score.should eql(600)
    @dice.number_of_non_scoring.should eql(0)
  end

  it "should have a score of the mixed sum and zero non-scoring dice for a roll of all scoring dice" do
    @dice.roll([2,2,2,5,5])
    @dice.score.should eql(300)
    @dice.number_of_non_scoring.should eql(0)
    @dice.roll([5,5,5,5])
    @dice.score.should eql(550)
    @dice.number_of_non_scoring.should eql(0)
  end

  it "should have a score of the mixed sum and N non-scoring dice for a roll with N non-scoring dice" do
    @dice.roll([2,3,4,5,5])
    @dice.score.should eql(100)
    @dice.number_of_non_scoring.should eql(3)
    @dice.roll([5,5,5,6,4])
    @dice.score.should eql(500)
    @dice.number_of_non_scoring.should eql(2)
  end
 end