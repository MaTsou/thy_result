require_relative 'test_helper.rb'
require_relative '../lib/thy_result.rb'

describe ThyResult do
  class MissingBudget < ThyResult; end
  class MissingSubscription < ThyResult; end
  class MissingPlanChoice < ThyResult; end

  describe "When content is single" do

    it "simply works" do
      _( MissingBudget[1].call ).must_equal 1
      _( MissingBudget[2].content ).must_equal 2
      _( MissingBudget[2].call ).wont_equal 1
      _( MissingBudget[3].isMissingBudget { |a| a } ).must_equal 3
      _( MissingBudget[3].is( MissingBudget ) { |a| a } ).must_equal 3
      _( MissingBudget[3].is( :MissingBudget ) { |a| a } ).must_equal 3
      _( ThyResult.set( :You, 3 ).is( :You ) { |a| a } ).must_equal 3
    end

    it "works like this too" do
      _(
        case result = MissingBudget[1]
        when MissingSubscription
          "hello #{result.call}"
        when MissingBudget
          "tested last : #{result.call}"
        else
          "nothing there"
        end
      ).must_equal "tested last : 1"
    end

    %w( budget subscription plan_choice ).each do |type|
      expected = "class is 1"
      expected = "subs is 1" if type == 'subscription'
      it "missing_#{type} only execute the eponym method block" do
        _(
          yield_result( type ) do |state|
            state.is( :MissingSubscription ) { |content| "subs is #{content}" }
            state.is( state.class ) { |content| "class is #{content}" }
            state.isMissingPlanChoice { |content| "hello there #{content}" }
          end
        ).must_equal expected

      end
    end
  end

  describe "when content is multiple" do
    it "simply works" do
      _( MissingBudget[1, 2].call ).must_equal [1, 2]
      _( MissingBudget[2, 3].content ).must_equal [2,3]
      _( MissingBudget[2, 3].call ).wont_equal 2
      _( MissingBudget[3,4].isMissingBudget { |a,b| "#{a}-#{b}" } ).must_equal "3-4"
    end

    %w( budget subscription plan_choice ).each do |type|
      expected = "class is a-b"
      expected = "subs is a-b" if type == 'subscription'
      it "missing_#{type} only execute the eponym method block" do
        _(
          yield_multiple_result( type ) do |state|
            state.is( MissingSubscription ) { |a,b| "subs is #{a}-#{b}" }
            state.is( state.class ) { |a,b| "class is #{a}-#{b}" }
            state.is( MissingPlanChoice ) { |a,b| "hello there" }
          end
        ).must_equal expected

      end
    end
  end

  describe "when content is callable" do
    %w( mybudget mysubscription myplan_choice ).each do |type|
      expected = "class is a1-b2"
      expected = "subs is a1-b2" if type == 'mysubscription'
      it "missing_#{type} only execute the eponym method block" do
        _(
          yield_multiple_callable_result( type ) do |state|
            state.isMysubscription { |a,b| "subs is #{a.(1)}-#{b.(2)}" }
            state.is( :Myplan_choice ) { |a,b| "hello there" }
            state.is( state.class ) { |a,b| "class is #{a.(1)}-#{b.(2)}" }
          end
        ).must_equal expected

      end
    end
  end

  describe "when on the fly ThyResult creation" do
    it "works as expected" do
      _( ThyResult.set( :HelloWorld, 2 ).content ).must_equal 2
      _( ThyResult.set( :MyNameIs, 2 ).call ).wont_equal 1
      _( ThyResult.set( :You, 3 ).isYou { |a| a } ).must_equal 3
      _( ThyResult.set( :You, 3 ).is( :You ) { |a| a } ).must_equal 3
      _( ThyResult.set( :You, 3 ).is( You ) { |a| a } ).must_equal 3
    end

    it "works like this too" do
      _(
        case result = ThyResult.set( :MissingMe, 1 )
        when MissingSubscription
          "hello #{result.call}"
        when MissingMe
          "tested last : #{result.call}"
        else
          "nothing here"
        end
      ).must_equal "tested last : 1"
    end
  end

  private

  def camelize( str )
    str.split('_').map(&:capitalize).join
  end

  def return_result( type )
    get_class( type )[1]
  end

  def yield_result( type )
    yield ThyResult.set( camelize( method_name( type ) ), 1 )
  end

  def yield_multiple_result( type )
    yield get_class( type )['a', 'b']
  end

  def yield_multiple_callable_result( type )
    yield ThyResult.set( camelize( type ), -> ( i ) { "a#{i}" }, -> ( j ) { "b#{j}" } )
  end

  def get_class( type )
    Object.const_get( camelize( method_name( type ) ) )
  end

  def get_missing_budget
    yield ThyResult.set( :MissingBudget, 1 )
  end

  def method_name( type )
    "missing_#{type}"
  end
end

