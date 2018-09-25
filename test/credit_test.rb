gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
require_relative '../lib/credit'
require_relative '../lib/person'

class CreditTest < Minitest::Test
  def setup
    @credit = Credit.new("AMEX")
    @person = Person.new("Ron", 100)
    @person_2 = Person.new("Harry", 500)
    @credit.open_credit(@person_2, 1000, 0.13)
  end

  def test_has_name
    assert_equal :AMEX, @credit.name
  end

  def test_can_open_a_line_of_credit
    @credit.open_credit(@person, 1000, 0.13)
    assert_equal ({balance: 0, limit: 1000, interest_rate: 0.13}),
    @person.credit_card_accounts[@credit.name]
  end

  def test_can_spend_on_credit_card
    @credit.cc_spend(@person_2, 500)

    assert_equal ({balance: 500, limit: 500, interest_rate: 0.13}),
    @person_2.credit_card_accounts[@credit.name]
  end

  def test_cant_spend_more_than_limit
    assert_equal "Harry cannot spend over their limit",
    @credit.cc_spend(@person_2, 1001)
  end

  def test_can_pay_off_credit_card
    @credit.cc_spend(@person_2, 500)

    assert_equal ({balance: 500, limit: 500, interest_rate: 0.13}),
    @person_2.credit_card_accounts[@credit.name]

    @credit.cc_pay_off(@person_2, 500)
    assert_equal ({balance: 0, limit: 1000, interest_rate: 0.13}),
    @person_2.credit_card_accounts[@credit.name]
  end

  def test_cant_pay_off_credit_card_if_insufficient_funds
    @credit.cc_spend(@person_2, 501)

    assert_equal ({balance: 501, limit: 499, interest_rate: 0.13}),
    @person_2.credit_card_accounts[@credit.name]

    assert_equal "Harry does not have enough galleons for this transaction",
    @credit.cc_pay_off(@person_2, 501)
  end
end
