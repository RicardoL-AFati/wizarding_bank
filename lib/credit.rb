class Credit
  attr_reader :name
  def initialize(name)
    @name = name.to_sym
  end

  def open_credit(person, interest_rate, limit = {galleons: 1, silver_sickles: 17, bronze_knuts: 29})
    person.credit_card_accounts[name] = {
      balance: {galleons: 0, silver_sickles: 0, bronze_knuts: 0},
      limit: limit,
      interest_rate: interest_rate
    }
  end

  def cc_spend(person, charge)
    if is_under_or_at_limit?(person, charge)
      update_account(person, charge, :charge)
    else
      over_limit_message(person, charge)
    end
  end

  def cc_pay_off(person, payment)
    if not enough_cash?(person, payment)
      not_enough_cash_to_pay_debts_message(person, payment)
    else
      update_account(person, payment, :payment)
    end
  end

  def update_account(person, transaction, type)
    change_limit(person, transaction, type)
    change_balance(person, transaction, type)
  end

  def change_limit(person, transaction, type)
    transaction.each do |denomination, amount|
      if type == :payment
        person.credit_card_accounts[name][:limit][denomination] += amount
      else
        person.credit_card_accounts[name][:limit][denomination] -= amount
      end
    end
  end

  def change_balance(person, transaction, type)
    transaction.each do |denomination, amount|
      if type == :payment
        person.credit_card_accounts[name][:balance][denomination] -= amount
      else
        person.credit_card_accounts[name][:balance][denomination] += amount
      end
    end
  end

  def is_under_or_at_limit?(person, charge)
    check_spending = charge.reduce(true) do |under_or_at, (denomination, amount)|
      under_or_at = false if amount > person.credit_card_accounts[name][:limit][denomination]
      under_or_at
    end
  end

  def enough_cash?(person, payment)
    payment.reduce(true) do |enough, (denomination, amount)|
      enough = false if amount > person.cash[denomination]
      enough
    end
  end

  def over_limit_message(person, charge)
    currency = charge.find do |denomination, amount|
      amount > person.credit_card_accounts[name][:limit][denomination]
    end
    "#{person.name} cannot spend over their limit for #{currency[0].to_s.sub('_', ' ')}"
  end

  def not_enough_cash_to_pay_debts_message(person, payment)
    currency = payment.find do |denomination, amount|
      amount > person.cash[denomination]
    end
    "#{person.name} does not have enough #{currency[0].to_s.sub('_', ' ')} for this payment"
  end
end
