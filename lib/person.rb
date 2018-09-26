class Person
  attr_reader :name
  attr_accessor :cash, :bank_accounts, :credit_card_accounts
  def initialize(name, cash = {})
    @name = name
    @cash = {
      galleons: cash[:galleons] || 0,
      silver_sickles: cash[:silver_sickles] || 0,
      bronze_knuts: cash[:bronze_knuts] || 0
    }
    @bank_accounts = {}
    @credit_card_accounts = {}
  end
end
