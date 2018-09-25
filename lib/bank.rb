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
    if has_enough?(person, deposit)
      add_to_account(person, deposit)
      remove_from_cash(person, deposit)
    else
      not_enough_funds_message(person, 'deposit')
    end
  end

  def withdrawal(person, amount)
    return no_account_message(person) if not has_account?(person)
    if has_enough_galleons_in_account?(person, amount)
      person.bank_accounts[name] -= amount
      person.galleons += amount
    else
      not_enough_funds_message(person, 'withdrawal')
    end
  end

  def transfer(person, other_bank, amount)
    if has_accounts_with_both?(person, other_bank)
      if has_enough_galleons_in_account?(person, amount)
        person.bank_accounts[name] -= amount
        person.bank_accounts[other_bank.name] += amount
      else
        not_enough_funds_message(person, 'transfer')
      end
    else
      no_account_message_banks(person, other_bank)
    end
  end

  def total_cash(person)
    return no_account_message(person) if not has_account?(person)
    "#{person.bank_accounts[name]} galleons"
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

  def not_enough_funds_message(person, transaction_type)
    "#{person.name} does not have enough funds for this #{transaction_type}"
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

  def has_enough?(person, deposit)
    enough = true
    deposit.each do |denomination, amount|
      enough = false if amount > person.bank_accounts[name][denomination]
    end
    enough
  end

  def has_enough_galleons_in_account?(person, amount)
    person.bank_accounts[name] >= amount
  end
end
