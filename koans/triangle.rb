# Triangle Project Code.

# Triangle analyzes the lengths of the sides of a triangle
# (represented by a, b and c) and returns the type of triangle.
#
# It returns:
#   :equilateral  if all sides are equal
#   :isosceles    if exactly 2 sides are equal
#   :scalene      if no sides are equal
#
# The tests for this method can be found in
#   about_triangle_project.rb
# and
#   about_triangle_project_2.rb
#
def triangle(a, b, c)
  unless side_lengths_define_valid_triangle?(a,b,c)
      raise TriangleError, "The specified side lengths do not define a valid triangle!"
  end
  
  if is_equilateral?(a,b,c)
    :equilateral 
  elsif is_isosceles?(a,b,c)
    :isosceles
  else
    :scalene
  end
end

#   :equilateral  if all sides are equal
def is_equilateral?(a,b,c)
  return (a==b and b==c)
end

#   :isosceles    if exactly 2 sides are equal
def is_isosceles?(a,b,c)
  if (a==b and b!=c) || (a!=b and a==c) || (a!=b and b==c)
    return true
  else
    return false
  end
end

# checks to see if the side lengths can possibly define a triangle
def side_lengths_define_valid_triangle?(a,b,c)  
  # side length can not be zero or less
  if a<=0 or b<=0 or c<=0 
    return false 
  end
  
  # sum of any two sides must be greater than third side
  if (a+b<=c) || (a+c<=b) || (b+c<=a)
    return false
  end
  
  return true
end

# Error class used in part 2.  No need to change this code.
class TriangleError < StandardError
end
