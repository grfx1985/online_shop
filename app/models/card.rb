# {Payment} user`s address
# @author Pawel Adamski
class Card
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :card_number, :expiration_month, :expiration_year, :name_on_card, :card_code

  validates_presence_of :card_number, :expiration_month, :expiration_year, :name_on_card, :card_code

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end