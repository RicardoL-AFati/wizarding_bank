class Bank
  attr_reader :name
  def initialize(name)
    @name = name.to_sym
  end

  def open_account(person)
    person.bank_accounts[name] = {
      galleons: 0,
      silver_sickles: 0,
      bronze_knuts: 0
    }
  end

  def deposit(person, deposit)
    return no_account_message(person) if not has_account?(person)
    if has_enough_cash?(person, deposit)
      add_to_account(person, deposit)
      remove_from_cash(person, deposit)
    else
      not_enough_cash_for_deposit_message(person, deposit)
    end
  end

  def withdrawal(person, withdrawal)
    return no_account_message(person) if not has_account?(person)
    if has_enough_in_account?(person, withdrawal)
      remove_from_account(person, withdrawal)
      add_to_cash(person, withdrawal)
    else
      not_enough_in_account_message(person, withdrawal, :withdrawal)
    end
  end

  def transfer(person, other_bank, transfer)
    if has_accounts_with_both?(person, other_bank)
      if has_enough_in_account?(person, transfer)
        remove_from_account(person, transfer)
        other_bank.add_to_account(person, transfer)
      else
        not_enough_in_account_message(person, transfer, :transfer)
      end
    else
      no_account_message_banks(person, other_bank)
    end
  end

  def add_to_account(person, deposit)
    deposit.each do |denomination, amount|
      person.bank_accounts[name][denomination] += amount
    end
  end

  def remove_from_account(person, withdrawal)
    withdrawal.each do |denomination, amount|
      person.bank_accounts[name][denomination] -= amount
    end
  end

  def add_to_cash(person, withdrawal)
    withdrawal.each do |denomination, amount|
      person.cash[denomination] += amount
    end
  end

  def remove_from_cash(person, deposit)
    deposit.each do |denomination, amount|
      person.cash[denomination] -= amount
    end
  end

  def total_cash(person)
    return no_account_message(person) if not has_account?(person)
    total_cash = person.bank_accounts[name].reduce("") do |cash_string, (denomination, amount)|
      cash_string += " and #{amount} #{denomination.to_s.sub('_', ' ')}" unless denomination == :galleons
      if denomination == :galleons
        cash_string += "#{person.name} has #{amount} #{denomination.to_s.sub('_', ' ')}"
      end
      cash_string
    end
  end

  def has_account?(person)
    person.bank_accounts.key?(name)
  end

  def has_accounts_with_both?(person, other_bank)
    has_account?(person) && other_bank.has_account?(person)
  end

  def no_account_message(person)
    "#{person.name} does not have an account with #{name}"
  end

  def no_account_message_banks(person, other_bank)
    unless other_bank.has_account?(person)
      other_bank.no_account_message(person)
    else
      no_account_message(person)
    end
  end

  def not_enough_cash_for_deposit_message(person, deposit)
    currency = deposit.find do |denomination, amount|
      amount > person.cash[denomination]
    end
    "#{person.name} does not have enough #{currency[0].to_s.sub('_', ' ')} for this deposit"
  end


  def not_enough_in_account_message(person, withdrawal_or_transfer, type)
    currency = withdrawal_or_transfer.find do |denomination, amount|
      amount > person.bank_accounts[name][denomination]
    end
    "#{person.name} does not have enough #{currency[0].to_s.sub('_', ' ')} in their account for this #{type.to_s}"
  end

  def calculate_value(currencies)
    silver_sickles =
      currencies[:silver_sickles] +
      change(:silver_sickles, :bronze_knuts, currencies[:bronze_knuts])
    bronze_knuts = currencies[:bronze_knuts] % 29
    final_value = {
      galleons: currencies[:galleons],
      silver_sickles: silver_sickles,
      bronze_knuts: bronze_knuts
    }
  end

  def change(to_currency, from_currency, amount)
    if from_currency == :galleons
      to_currency == :silver_sickles ?
        amount * 17 : amount * 493
    elsif from_currency == :silver_sickles
      to_currency == :galleons ?
        amount / 17 : amount * 29
    else
      to_currency == :galleons ?
        amount / 493 : amount / 29
    end
  end

  def has_enough_cash?(person, deposit)
    enough = true
    deposit.each do |denomination, amount|
      enough = false if amount > person.cash[denomination]
    end
    enough
  end

  def has_enough_in_account?(person, withdrawal)
    enough = true
    withdrawal.each do |denomination, amount|
      enough = false if amount > person.bank_accounts[name][denomination]
    end
    enough
  end


end
