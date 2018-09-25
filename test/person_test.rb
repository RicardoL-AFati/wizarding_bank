gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/person'

class PersonTest < Minitest::Test
  def setup
    @person = Person.new('Ron', 100)
  end

  def test_has_name
    assert_equal 'Ron', @person.name
  end

end
