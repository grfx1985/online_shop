class AdminController < ApplicationController
  def index
    @total_orders = Order.count
    @total_contacts = Contact.count
  end
end
