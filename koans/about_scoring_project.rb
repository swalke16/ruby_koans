require 'edgecase'

# Greed is a dice game where you roll up to five dice to accumulate
# points.  The following "score" function will be used calculate the
# score of a single roll of the dice.
#
# A greed roll is scored as follows:
#
# * A set of three ones is 1000 points
#   
# * A set of three numbers (other than ones) is worth 100 times the
#   number. (e.g. three fives is 500 points).
#
# * A one (that is not part of a set of three) is worth 100 points.
#
# * A five (that is not part of a set of three) is worth 50 points.
#
# * Everything else is worth 0 points.
#
#
# Examples:
#
# score([1,1,1,5,1]) => 1150 points
# score([2,3,4,6,2]) => 0 points
# score([3,4,5,3,3]) => 350 points
# score([1,5,1,2,4]) => 250 points
#
# More scoing examples are given in the tests below:
#
# Your goal is to write the score method.

def score(dice)
  count_digits(dice).inject(0){ |score, item| score + score_for_digit(item[0],item[1]) }
end

def count_digits(dice)
  digit_counts = Hash.new(0)
  dice.each{ |item|
      digit_counts[item] += 1
    }
    
  return digit_counts
end

def score_for_digit(digit, count)
  score=0

  if count >= 3
    score += triple_digit_score(digit) + sum_digit_score(digit, count-3)
  else
    score += sum_digit_score(digit, count)
  end

  return score
end

def triple_digit_score(digit)
  if digit == 1
    1000
  else
    digit * 100
  end
end

def sum_digit_score(digit, count)
  if digit == 1
    count*100
  elsif digit == 5
    count*50
  else
    0
  end
end

class AboutScoringAssignment < EdgeCase::Koan
  def test_score_of_an_empty_list_is_zero
    assert_equal 0, score([])
  end

  def test_score_of_a_single_roll_of_5_is_50
    assert_equal 50, score([5])
  end

  def test_score_of_a_single_roll_of_1_is_100
    assert_equal 100, score([1])
  end

  def test_score_of_mulitple_1s_and_5s_is_the_sum
    assert_equal 300, score([1,5,5,1])
  end

  def test_score_of_single_2s_3s_4s_and_6s_are_zero
    assert_equal 0, score([2,3,4,6])
  end

  def test_score_of_a_triple_1_is_1000
    assert_equal 1000, score([1,1,1])
  end

  def test_score_of_other_triples_is_100x
    assert_equal 200, score([2,2,2])
    assert_equal 300, score([3,3,3])
    assert_equal 400, score([4,4,4])
    assert_equal 500, score([5,5,5])
    assert_equal 600, score([6,6,6])
  end

  def test_score_of_mixed_is_sum
    #assert_equal 50, score([2,5,2,2,3])
    # I believe the original code had a bug here... Shouldn't the above assert be asserting a 
    # score of 250? 
    #3x2s = 100*2 = 200
    #1x5   = 50
    #Total: 250
    assert_equal 250, score([2,5,2,2,3])
    assert_equal 550, score([5,5,5,5])
  end

end
