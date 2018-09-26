gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
require_relative '../lib/bank'
require_relative '../lib/person'

class BankTest < Minitest::Test
  def setup
    @person = Person.new('Ron', galleons: 10, silver_sickles: 15, bronze_knuts: 25)
    @person_2 = Person.new('Harry', galleons: 10, silver_sickles: 15, bronze_knuts: 25)
    @bank = Bank.new('Chase')
    @bank_2 = Bank.new('Wells Fargo')
    @bank_2.open_account(@person_2)
    @bank_2.deposit(@person_2, galleons: 5, silver_sickles: 10, bronze_knuts: 20)
  end

  def test_has_name
    assert_equal :Chase, @bank.name
  end

  def test_can_make_an_account
    @bank.open_account(@person)
    assert_equal ({galleons: 0, silver_sickles: 0, bronze_knuts: 0}),
    @person.bank_accounts[@bank.name]
  end

  def test_takes_a_deposit
    @bank.open_account(@person)
    @bank.deposit(@person, galleons: 5, silver_sickles: 10, bronze_knuts: 20)

    assert_equal ({galleons: 5, silver_sickles: 5, bronze_knuts: 5 }),
    @person.cash
    assert_equal ({galleons: 5, silver_sickles: 10, bronze_knuts: 20}),
    @person.bank_accounts[@bank.name]
  end

  def test_can_take_deposit_with_only_some_denominations
    @bank.open_account(@person)
    @bank.deposit(@person, galleons: 5, silver_sickles: 5)

    assert_equal ({galleons: 5, silver_sickles: 5, bronze_knuts: 0}),
    @person.bank_accounts[@bank.name]
    assert_equal ({galleons: 5, silver_sickles: 10, bronze_knuts: 25}),
    @person.cash
  end

  def test_cant_take_deposit_if_insufficient_galleons
    @bank.open_account(@person)
    assert_equal "Ron does not have enough galleons for this deposit",
    @bank.deposit(@person, galleons: 11, silver_sickles: 15, bronze_knuts: 25)
  end

  def test_cant_take_deposit_if_insufficient_silver_sickles
    @bank.open_account(@person)
    assert_equal "Ron does not have enough silver sickles for this deposit",
    @bank.deposit(@person, galleons: 10, silver_sickles: 16, bronze_knuts: 25)
  end

  def test_cant_take_deposit_if_insufficient_bronze_knuts
    @bank.open_account(@person)
    assert_equal "Ron does not have enough bronze knuts for this deposit",
    @bank.deposit(@person, galleons: 10, silver_sickles: 15, bronze_knuts: 26)
  end

  def test_cant_take_deposit_if_no_account
    assert_equal "Ron does not have an account with Chase",
    @bank.deposit(@person, galleons: 10, silver_sickles: 15, bronze_knuts: 25)
  end

  def test_can_make_a_withdrawal
    assert_equal ({galleons: 5, silver_sickles: 10, bronze_knuts: 20}),
    @person_2.bank_accounts[@bank_2.name]
    assert_equal ({galleons: 5, silver_sickles: 5, bronze_knuts: 5}),
    @person_2.cash

    @bank_2.withdrawal(@person_2, galleons: 2, silver_sickles: 2, bronze_knuts: 10)
    assert_equal ({galleons: 3, silver_sickles: 8, bronze_knuts: 10}),
    @person_2.bank_accounts[@bank_2.name]

    assert_equal ({galleons: 7, silver_sickles: 7, bronze_knuts: 15}),
    @person_2.cash
  end


  def test_can_make_a_withdrawal_with_only_some_denominations
    assert_equal ({galleons: 5, silver_sickles: 10, bronze_knuts: 20}),
    @person_2.bank_accounts[@bank_2.name]
    assert_equal ({galleons: 5, silver_sickles: 5, bronze_knuts: 5}),
    @person_2.cash

    @bank_2.withdrawal(@person_2, galleons: 2, bronze_knuts: 10)
    assert_equal ({galleons: 3, silver_sickles: 10, bronze_knuts: 10}),
    @person_2.bank_accounts[@bank_2.name]

    assert_equal ({galleons: 7, silver_sickles: 5, bronze_knuts: 15}),
    @person_2.cash
  end

  def test_cant_overwithdraw_account
    assert_equal "Harry does not have enough galleons in their account for this withdrawal",
    @bank_2.withdrawal(@person_2, galleons: 7, silver_sickles: 5, bronze_knuts: 10)
  end

  def test_cant_overwithdraw_account_different_denomination
    assert_equal "Harry does not have enough silver sickles in their account for this withdrawal",
    @bank_2.withdrawal(@person_2, galleons: 2, silver_sickles: 11, bronze_knuts: 10)
  end

  def test_cant_withdraw_if_no_account
    assert_equal "Ron does not have an account with Chase",
    @bank.withdrawal(@person, galleons: 5, silver_sickles: 5, bronze_knuts: 15)
  end

  def test_can_transfer_money_to_account
    @bank.open_account(@person_2)
    @bank.deposit(@person_2, galleons: 5, silver_sickles: 5, bronze_knuts: 5)

    assert_equal ({galleons: 5, silver_sickles: 5, bronze_knuts: 5}),
    @person_2.bank_accounts[@bank.name]

    @bank.transfer(@person_2, @bank_2, {galleons: 2, silver_sickles: 2, bronze_knuts: 2})
    assert_equal ({galleons: 3, silver_sickles: 3, bronze_knuts: 3}),
    @person_2.bank_accounts[@bank.name]
    assert_equal ({galleons: 7, silver_sickles: 12, bronze_knuts: 22}),
    @person_2.bank_accounts[@bank_2.name]
  end

  def test_cant_transfer_money_if_insufficient_funds
    @bank.open_account(@person_2)
    @bank.deposit(@person_2, galleons: 5, silver_sickles: 5, bronze_knuts: 5)

    assert_equal ({galleons: 5, silver_sickles: 5, bronze_knuts: 5}),
    @person_2.bank_accounts[@bank.name]

    assert_equal "Harry does not have enough galleons in their account for this transfer",
    @bank.transfer(@person_2, @bank_2, {galleons: 6, silver_sickles: 2, bronze_knuts: 2})
  end

  def test_cant_transfer_money_if_insufficient_funds_other_denomination
    @bank.open_account(@person_2)
    @bank.deposit(@person_2, galleons: 5, silver_sickles: 5, bronze_knuts: 5)

    assert_equal ({galleons: 5, silver_sickles: 5, bronze_knuts: 5}),
    @person_2.bank_accounts[@bank.name]

    assert_equal "Harry does not have enough silver sickles in their account for this transfer",
    @bank.transfer(@person_2, @bank_2, {galleons: 2, silver_sickles: 6, bronze_knuts: 2})
  end

  def test_cant_transfer_money_if_no_account_with_current_bank
    assert_equal "Harry does not have an account with Chase",
    @bank.transfer(@person_2, @bank_2, galleons: 2, silver_sickles: 2, bronze_knuts: 2)
  end

  def test_cant_transfer_money_if_no_account_with_other_bank
    @bank.open_account(@person)

    assert_equal ({galleons: 0, silver_sickles: 0, bronze_knuts: 0}),
    @person.bank_accounts[@bank.name]
    assert_equal "Ron does not have an account with Wells Fargo",
    @bank_2.transfer(@person, @bank, galleons: 2, silver_sickles: 2, bronze_knuts: 2)
  end

  def test_can_retrieve_total_cash_from_account
    assert_equal "Harry has 5 galleons and 10 silver sickles and 20 bronze knuts",
    @bank_2.total_cash(@person_2)
  end
end
