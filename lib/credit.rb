class Credit
  attr_reader :name
  def initialize(name)
    @name = name.to_sym
  end

  def open_credit(person, limit, interest_rate)
    person.credit_card_accounts[name] = {
      balance: 0,
      limit: limit,
      interest_rate: interest_rate
    }
  end

  def cc_spend(person, amount)
    if not is_under_or_at_limit?(person, amount)
      "#{person.name} cannot spend over their limit"
    else
      person.credit_card_accounts[name][:limit] -= amount
      person.credit_card_accounts[name][:balance] += amount
    end
  end

  def is_under_or_at_limit?(person, amount)
    person.credit_card_accounts[name][:limit] >= amount
  end

  def cc_pay_off(person, amount)
    if not enough_galleons?(person, amount)
      "#{person.name} does not have enough galleons for this transaction"
    else
      person.credit_card_accounts[name][:balance] -= amount
      person.credit_card_accounts[name][:limit] += amount
    end
  end

  def enough_galleons?(person, amount)
    person.galleons >= amount
  end
end
