gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/person'

class PersonTest < Minitest::Test
  def setup
    @person = Person.new('Ron')
  end

  def test_has_name
    assert_equal 'Ron', @person.name
  end

  def test_created_with_no_cash_by_default
    assert_equal ({galleons: 0, silver_sickles: 0, bronze_knuts: 0}),
    @person.cash
  end

  def test_can_be_created_with_cash
    @person_2 = Person.new('Harry', galleons: 500, silver_sickles: 300, bronze_knuts: 1000)
    assert_equal ({galleons: 500, silver_sickles: 300, bronze_knuts: 1000}),
    @person_2.cash
  end

  def test_created_with_no_bank_accounts
    assert_equal ({}), @person.bank_accounts
  end

  def test_created_with_no_credit_card_accounts
    assert_equal ({}), @person.credit_card_accounts
  end
end
