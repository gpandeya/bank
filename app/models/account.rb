class Account < ApplicationRecord
    
    has_many :transactions
    validates :name, uniqueness: true
    validates :name, :category, presence: true
    
    after_save :check_suspension
    
    def deposits()
        self.transactions.where(category: 'Deposit')
    end
    
    def withdraws()
        self.transactions.where(category: 'Withdraw')
    end
    
    def overdrafts()
        self.transactions.where(category: 'Overdraft')
    end
    
    def deposit(amount)
   
        
        return if check_amount(amount).any?
        
        ActiveRecord::Base.transaction do
            self.update!(balance: self.balance + amount)
            #raise 'explode'
            Transaction.create!(amount: amount, category: 'Deposit' , account_id: self.id)
        end
    end
    
    def withdraw(amount)
        
        return if check_amount(amount).any?
        
        return if check_account_suspension().any?
        
        if  self.balance >= amount
            ActiveRecord::Base.transaction do
                self.update!(balance: self.balance - amount)
                Transaction.create!(amount: amount, category: 'Withdraw' , account_id: self.id)
            end
        else
            ActiveRecord::Base.transaction do
                self.update!(balance: self.balance - 50, flags: self.flags+1)
                Transaction.create!(amount: 50, category: 'Overdraft' , account_id: self.id)
            end
            
        end
    end
    
    def clear_suspension
        return if insufficent_funds
          ActiveRecord::Base.transaction do
                self.update!(balance: self.balance - 100, is_suspended: false)
                Transaction.create!(amount: 100, category: 'Unfreeze' , account_id: self.id)
            end
        
    end
    
    private 
    
    def insufficent_funds
     self.errors.add(:account, 'does not have insufficent funds') if self.balance <100
     self.errors.any?
    end
    
    def check_amount(amount)
    
        if !amount.is_a? Numeric
            self.errors.add(:amount, 'not a number') 
        end
        
        self.errors.add(:amount, 'less than zero') if amount<=0
        self.errors
    end
    
    def check_suspension()
        
        if self.flags > 3
            self.update!(is_suspended: true, flags: 0)
        end
        
    end
    
    def check_account_suspension()
        self.errors.add(:is_suspended, 'account is suspended.') 
    end
    
end