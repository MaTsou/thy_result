# frozen_string_literal: true

require_relative "thy_result/version"

class ThyResult
  attr_reader :content

  def initialize( content, *args )
    @content = args.empty? ? content : args.unshift( content )
    @final = nil
  end

  def self.[]( content, *args )
    new( content, *args )
  end

  # on the fly Result creation
  # Result.set( :Success, 'hello' )
  # leads to a Success object subclassing Result..
  def self.set( klass, content = true, *args )
    set_result_class( klass ).new( content, *args )
  end

  def call( *args, **options, &block )
    return content unless content.respond_to? :call
    content.call( *args, **options, &block )
  end

  def method_missing( name, *args, **options, &block )
    return super unless name.to_s =~ /^is/
    is( name.to_s.gsub( /^is/, '' ), &block )
  end

  def is( klass, &block )
    klass = set_result_class( klass )
    @final ||= ( yield content if is_a? klass )
  end

  private

  def to_class( name )
    # Better not to use Rails specific code (constantize !)
    Object.const_get( name )
  end

  def self.set_result_class( klass )
    case klass
    when Symbol, String
      Object.const_defined?( klass ) ?
        Object.const_get( klass ) :
        Object.const_set( klass, Class.new( self ) )
    when self.class
      klass
    end
  end

  def set_result_class( klass )
    self.class.set_result_class( klass )
  end
end
# Expected syntax
# 1/
# res = Result.new( 'my name' )
# res.call -> 'my_name'
# res.content -> 'my_name'
# res.is( Result ) { |str| here str = 'my_name' }
# res.isResult { |str| here str = 'my_name' }
#
# 2/
# res = Result.new( 'my_name', 'your_name' )
# res.call -> [ 'my_name', 'your_name' ]
# res.content -> [ 'my_name', 'your_name' ]
# res.is( Result ) { |str_a, str_b| here str_a = 'my_name', str_b = 'your_name' }
# res.isResult { |str_a, str_b| here str_a = 'my_name', str_b = 'your_name' }
#
# 3/
# res = Result.new( -> ( *args, **options, &block ) { lambda code } )
# res.call( a, b, c: 'hello' )
#   -> execute lambda with args = a, b ; options = c.hello
# res.call( a, b, c: 'hello' ) { |x, y| block code }
#   -> execute lambda with args = a, b ; options = c.hello and execute block if 
#   lambda contains a 'yield x, y' line...
#
# Describing results :
# method_yielding_a_result do |access|
#   access.isGranted { |*content| ... }
#   access.isDenied { |*content| ... }
# end
# or
# method_yielding_a_result do |access|
#   access.is( :Granted ) { |*content| ... }
#   access.is( :Denied ) { |*content| ... }
# end
