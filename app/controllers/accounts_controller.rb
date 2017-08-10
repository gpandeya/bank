class AccountsController < ApplicationController
    
    def index
        @accounts = Account.order(id: :desc)
    end
    
    def atm
        @account = Account.find(params[:id])
        
    end
    
    def deposit
        @account = Account.find(params[:id])
        @account.deposit(params[:amount].to_f)
        
        if @account.errors.any?
            render 'atm'
        else
            redirect_to root_url
        end
    end
    
    def withdraw
        
        @account = Account.find(params[:id])
        @account.withdraw(params[:amount].to_f)
        
        if @account.errors.any?
            render 'atm'
        else
            redirect_to root_url
        end
        
    end
    
    def unfreeze
        @account = Account.find(params[:id])
        @account.clear_suspension()
        
        if @account.errors.any?
            render 'atm'
        else
            redirect_to root_url
        end
    end
    
end