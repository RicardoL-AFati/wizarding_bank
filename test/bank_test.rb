gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
require_relative '../lib/bank'
require_relative '../lib/person'

class BankTest < Minitest::Test
  def setup
    @bank = Bank.new('Chase')
    @bank_2 = Bank.new('Wells Fargo')
    @person = Person.new('Ron', galleons: 10, silver_sickles: 15, bronze_knuts: 25)
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
    @bank.deposit(@person, galleons: 5, silver_sickles: 16)
    assert_equal 50, @person.cash
    assert_equal ({galleons: 5, silver_sickles: 16}), @person.bank_accounts[@bank.name]
  end

  def test_cant_take_deposit_if_insufficient_galleons
    @bank.open_account(@person)
    assert_equal "Ron does not have enough funds for this deposit",
    @bank.deposit(@person, 200)
  end

  def test_cant_take_deposit_if_no_account
    assert_equal "Ron does not have an account with Chase",
    @bank.deposit(@person, 50)
  end

  def test_can_make_a_withdrawal
    @bank.open_account(@person)
    @bank.deposit(@person, 50)

    assert_equal 50, @person.bank_accounts[@bank.name]
    assert_equal 50, @person.galleons

    @bank.withdrawal(@person, 50)
    assert_equal 0, @person.bank_accounts[@bank.name]
    assert_equal 100, @person.galleons
  end

  def test_cant_overwithdraw_account
    @bank.open_account(@person)
    @bank.deposit(@person, 50)

    assert_equal 50, @person.bank_accounts[@bank.name]
    assert_equal 50, @person.galleons

    assert_equal "Ron does not have enough funds for this withdrawal",
    @bank.withdrawal(@person, 100)
  end

  def test_cant_withdraw_if_no_account
    assert_equal "Ron does not have an account with Chase",
    @bank.withdrawal(@person, 100)
  end

  def test_can_transfer_money_to_account
    @bank.open_account(@person)
    @bank_2.open_account(@person)
    @bank.deposit(@person, 50)

    assert_equal 50, @person.bank_accounts[@bank.name]
    @bank.transfer(@person, @bank_2, 50)
    assert_equal 0, @person.bank_accounts[@bank.name]
    assert_equal 50, @person.bank_accounts[@bank_2.name]
  end

  def test_cant_transfer_money_if_insufficient_funds
    @bank.open_account(@person)
    @bank_2.open_account(@person)
    @bank.deposit(@person, 50)

    assert_equal 50, @person.bank_accounts[@bank.name]
    assert_equal "Ron does not have enough funds for this transfer",
    @bank.transfer(@person, @bank_2, 100)
  end

  def test_cant_transfer_money_if_no_account_with_current_bank
    @bank_2.open_account(@person)

    assert_equal 0, @person.bank_accounts[@bank_2.name]
    assert_equal "Ron does not have an account with Chase",
    @bank.transfer(@person, @bank_2, 50)
  end

  def test_cant_transfer_money_if_no_account_with_other_bank
    @bank.open_account(@person)

    assert_equal 0, @person.bank_accounts[@bank.name]
    assert_equal "Ron does not have an account with Wells Fargo",
    @bank_2.transfer(@person, @bank, 50)
  end

  def test_can_retrieve_total_cash_from_account
    @bank.open_account(@person)
    @bank.deposit(@person, 50)

    assert_equal 50, @person.bank_accounts[@bank.name]
    assert_equal "50 galleons", @bank.total_cash(@person)
  end
end
