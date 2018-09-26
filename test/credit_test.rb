gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/credit'
require_relative '../lib/person'

class CreditTest < Minitest::Test
  def setup
    @credit = Credit.new("AMEX")
    @person = Person.new("Ron")
    @person_2 = Person.new("Harry", galleons: 40, silver_sickles: 50, bronze_knuts: 500)
    @credit.open_credit(@person_2, 0.13, galleons: 50, silver_sickles: 100, bronze_knuts: 1000)
  end

  def test_has_name
    assert_equal :AMEX, @credit.name
  end

  def test_can_open_a_line_of_credit
    @credit.open_credit(@person, 0.13, galleons: 20, silver_sickles: 40, bronze_knuts: 100)
    assert_equal (
      {
        balance: {galleons: 0, silver_sickles: 0, bronze_knuts: 0},
        limit: {galleons: 20, silver_sickles: 40, bronze_knuts: 100},
        interest_rate: 0.13
        }),
    @person.credit_card_accounts[@credit.name]
  end

  def test_can_spend_on_credit_card
    @credit.cc_spend(@person_2, galleons: 25, silver_sickles: 25, bronze_knuts: 15)

    assert_equal (
      {
        balance: {galleons: 25, silver_sickles: 25, bronze_knuts: 15},
        limit: {galleons: 25, silver_sickles: 75, bronze_knuts: 985},
        interest_rate: 0.13
        }),
    @person_2.credit_card_accounts[@credit.name]
  end

  def test_cant_spend_more_than_limit
    assert_equal "Harry cannot spend over their limit for galleons",
    @credit.cc_spend(@person_2, galleons: 51, silver_sickles: 100, bronze_knuts: 1000)
  end

  def test_cant_spend_more_than_limit_other_denomination
    assert_equal "Harry cannot spend over their limit for silver sickles",
    @credit.cc_spend(@person_2, galleons: 50, silver_sickles: 101, bronze_knuts: 1000)
  end

  def test_can_pay_off_credit_card
    @credit.cc_spend(@person_2, galleons: 25, silver_sickles: 50, bronze_knuts: 500)

    assert_equal ({galleons: 25, silver_sickles: 50, bronze_knuts: 500}),
    @person_2.credit_card_accounts[@credit.name][:balance]

    @credit.cc_pay_off(@person_2, galleons: 25, silver_sickles: 50, bronze_knuts: 500)
    assert_equal (
      {
        balance: {galleons: 0, silver_sickles: 0, bronze_knuts: 0},
        limit: {galleons: 50, silver_sickles: 100, bronze_knuts: 1000},
        interest_rate: 0.13
        }),
    @person_2.credit_card_accounts[@credit.name]
  end

  def test_cant_pay_off_credit_card_if_insufficient_funds
    @credit.cc_spend(@person_2, galleons: 45, silver_sickles: 50, bronze_knuts: 500)

    assert_equal (
      {
        balance: {galleons: 45, silver_sickles: 50, bronze_knuts: 500},
        limit: {galleons: 5, silver_sickles: 50, bronze_knuts: 500},
        interest_rate: 0.13
        }),
    @person_2.credit_card_accounts[@credit.name]

    assert_equal "Harry does not have enough galleons for this payment",
    @credit.cc_pay_off(@person_2, galleons: 45, silver_sickles: 50, bronze_knuts: 500)
  end

  def test_cant_pay_off_credit_card_if_insufficient_funds_different_denomination
    @credit.cc_spend(@person_2, galleons: 40, silver_sickles: 55, bronze_knuts: 500)

    assert_equal (
      {
        balance: {galleons: 40, silver_sickles: 55, bronze_knuts: 500},
        limit: {galleons: 10, silver_sickles: 45, bronze_knuts: 500},
        interest_rate: 0.13
        }),
    @person_2.credit_card_accounts[@credit.name]

    assert_equal "Harry does not have enough silver sickles for this payment",
    @credit.cc_pay_off(@person_2, galleons: 40, silver_sickles: 55, bronze_knuts: 500)
  end
end
