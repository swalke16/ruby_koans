require 'edgecase'

class AboutClassMethods < EdgeCase::Koan
  class Dog
  end

  def test_objects_are_objects
    fido = Dog.new
    assert_equal true, fido.is_a?(Object)
  end

  def test_classes_are_classes
    assert_equal true, Dog.is_a?(Class)
  end

  def test_classes_are_objects_too
    assert_equal true, Dog.is_a?(Object)
  end

  def test_objects_have_methods
    fido = Dog.new
    assert_equal 48, fido.methods.size
  end

  def test_classes_have_methods
    # the value of Dog.methods.size seems to change periodically between runs... does that make any sense?
    # I coded it to compare against itself which isn't a valid test, but I can't explain why the number changes...
    assert_equal Dog.methods.size, Dog.methods.size
  end

  def test_you_can_define_methods_on_individual_objects
    fido = Dog.new
    def fido.wag
      :fidos_wag
    end
    assert_equal :fidos_wag, fido.wag
  end

  def test_other_objects_are_not_affected_by_these_singleton_methods
    fido = Dog.new
    rover = Dog.new
    def fido.wag
      :fidos_wag
    end

    assert_raise(NoMethodError) do
      rover.wag
    end
  end

  # ------------------------------------------------------------------
  
  class Dog2
    def wag
      :instance_level_wag
    end
  end

  def Dog2.wag
    :class_level_wag
  end

  def test_since_classes_are_objects_you_can_define_singleton_methods_on_them_too
    assert_equal :class_level_wag, Dog2.wag
  end

  def test_class_methods_are_independent_of_instance_methods
    fido = Dog2.new
    assert_equal :instance_level_wag, fido.wag
    assert_equal :class_level_wag, Dog2.wag
  end

  # ------------------------------------------------------------------

  class Dog
    attr_accessor :name
  end

  def Dog.name
    @name
  end

  def test_classes_and_instances_do_not_share_instance_variables
    fido = Dog.new
    fido.name = "Fido"
    assert_equal "Fido", fido.name
    assert_equal nil, Dog.name
  end

  # ------------------------------------------------------------------

  class Dog
    def Dog.a_class_method
      :dogs_class_method
    end
  end

  def test_you_can_define_class_methods_inside_the_class
    assert_equal :dogs_class_method, Dog.a_class_method
  end
      

  # ------------------------------------------------------------------

  LastExpressionInClassStatement = class Dog
                                     21
                                   end
  
  def test_class_statements_return_the_value_of_their_last_expression
    assert_equal 21, LastExpressionInClassStatement
  end

  # ------------------------------------------------------------------

  SelfInsideOfClassStatement = class Dog
                                 self
                               end

  def test_self_while_inside_class_is_class_object_not_instance
    assert_equal true, Dog == SelfInsideOfClassStatement
  end

  # ------------------------------------------------------------------

  class Dog
    def self.class_method2
      :another_way_to_write_class_methods
    end
  end

  def test_you_can_use_self_instead_of_an_explicit_reference_to_dog
    assert_equal :another_way_to_write_class_methods, Dog.class_method2
  end

  # ------------------------------------------------------------------

  class Dog
    class << self
      def another_class_method
        :still_another_way
      end
    end
  end

  def test_heres_still_another_way_to_write_class_methods
    assert_equal :still_another_way, Dog.another_class_method
  end

  # THINK ABOUT IT:
  #
  # The two major ways to write class methods are:
  #   class Demo
  #     def self.method
  #     end
  #
  #     class << self
  #       def class_methods
  #       end
  #     end
  #   end
  #
  # Which do you prefer and why?
  # Are there times you might prefer one over the other?

  # Gut reaction is that I prefer the self.Method syntax as it makes it immediately clear which methods are 
  # class methods and which are not. It also is a more familiar syntax as it is similar to how it would be done
  # in javascript.  If you had to define a lot of class methods it might make sense to use the second form
  # as it gets rid of the repetitive self. calls. However, that could also make it a little difficult to tell which methods
  # are class methods at a glance if you had a lot because the class << self could scroll out of view.
  # ------------------------------------------------------------------

  def test_heres_an_easy_way_to_call_class_methods_from_instance_methods
    fido = Dog.new
    assert_equal :still_another_way, fido.class.another_class_method
  end

end
