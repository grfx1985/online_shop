# Usable Tokens for {Order} or {User} usage
class Token < ActiveRecord::Base
  # Token type
  Types = {
    disposable: 0,
    iterative: 1
  }
  belongs_to :order
  attr_accessor :prefix
  attr_accessible :reduction, :times, :type_id, :user, :valid_to
  validates :token, uniqueness: true
  validates :valid_to, presence: true
  validates :type_id, inclusion: { in: Types.values,:message => "%{value} is not a valid type" }
  validates :prefix, length:  { minimum: 9, maximum: 9 }, if: :prefix?
  validates :token, length:  { minimum: 19, maximum: 19 }
  before_validation :generate_token
  # Token searching helper method
  def self.by_token token
    o = self.where("token = '#{token}' AND used IN(0)").first
    if o.nil?
      raise ActiveRecord::RecordNotFound and return
    else
      return o
    end
  end
  # ActiveScaffold helper method
  def to_label
    token
  end
  # Prefix helper for prefix
  def prefix?
    self.prefix.present?
  end
  private
  # Token string generation and default value
  # @param prefix [String] if set will generates all {Token}s with it. Else default is FQ-%YYMMDD%
  def generate_token
    self.prefix = "FQ-#{Time.zone.now.strftime("%y%m%d")}" if self.prefix.blank?
    if self.token.blank?
      token = make_token
      token = make_token until Token.where(token: "#{prefix}-#{token}").blank?
      self.token = "#{prefix}-#{token}"
    end
    if self.token_value.blank?
      self.token_value = 3600 * 24 # 1d
    end
  end
  # Actual token String generation
  def make_token
    "#{RandomGenerator.make_string(4)}-#{RandomGenerator.make_string(4)}".upcase
  end
end
