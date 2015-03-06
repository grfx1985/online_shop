# Abstract Payment class
# @author Pawel Adamski
class Payment
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming


  attr_accessor :type, :card, :address, :user
  validates_presence_of :user
  validates_presence_of :card, :address, if: lambda { self.type == 'card' }
  # Returns a new instance of {Payment}. Also related {Address},{Card} if passed
  def initialize(user, type, attributes = {})
    self.user = user
    self.type = type
    attributes.each do |name, value|
      case name
        when 'card'
          self.card=(Card.new(value))
        when 'address'
          self.address=(Address.new(value))
        when 'back_url'
          self.back_url= value
        else
          send("#{name}=", value)
      end
    end
  end
  # Not stored in DB
  def persisted?
    false
  end
  # Sets user info
  def user=(user)
    @user = user
  end
  # Sets {Card} info
  def card=(other_card)
    @card = other_card
  end
  # Sets {Address} info
  def address=(address)
    @address = address
  end
  # Return {Card} object
  # @return {Card}
  def card
    @card
  end
  # Return {Address} object
  # @return {Address}
  def address
    @address
  end
  # Validation method override. Adds {Card} and {Address} validation and errors for card type transactions
  def valid?
    super
    if type == 'card'
      unless card.valid?
        card.errors.each do | error, message |
          self.errors.add error, message
        end
      end
      unless address.valid?
        address.errors.each do | error, message |
          self.errors.add error, message
        end
      end
    end
    self.errors.blank?
  end
  # Return card_params for Paylane transaction
  # @param order    [Order] Order object
  # @param ip       [String] request IP address
  # @param back_url [String] url address to return to
  # @see PaymentsHelper#card_params
  def card_params order, ip, back_url
    PaymentsHelper::card_params @user, @card, @address, ip, order
  end
  # Return paylane_params for Paylane transaction
  # @param order    [Order] Order object
  # @param ip       [String] request IP address
  # @param back_url [String] url address to return to
  # @see PaymentsHelper#paypal_params
  def paypal_params order, ip, back_url
    PaymentsHelper::paypal_params @user, back_url, order
  end

end