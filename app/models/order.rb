class Order < ActiveRecord::Base
  PAYMENT_TYPES = [ "Pay Pal", "Card", "Bank Transfer" ]
  PAYMENT_DOC = [ "F-VAT", "Paragon" ]
  has_many :line_items, dependent: :destroy
  validates :name, :address, :email, :extra,  presence: true
  validates :pay_type, inclusion: PAYMENT_TYPES
  validates :doc, inclusion: PAYMENT_DOC
  validates :delivery_time, presence: true
  def add_line_items_from_cart(cart)
    cart.line_items.each do |item|
      item.cart_id = nil
      line_items << item
    end
  end

end 