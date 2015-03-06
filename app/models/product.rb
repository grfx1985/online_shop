class Product < ActiveRecord::Base
  has_many :line_items
  has_many :orders, through: :line_items
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "http://a.dryicons.com/images/icon_sets/coquette_part_3_icons_set/png/128x128/pages_warning.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  before_destroy :ensure_not_referenced_by_any_line_item

  validates :title, :description, presence: true
  validates :price, numericality: {greater_than_or_equal_to: 0.01}
 
  validates :title, uniqueness: true
  validates :image_url, allow_blank: true, format: {
    with:    %r{\.(gif|jpg|png)\Z}i,
    message: 'must be a URL for GIF, JPG or PNG image.'
  }
  validates :title, length: {minimum: 10}

  def self.latest
    Product.order(:updated_at).last
  end

  private


    def ensure_not_referenced_by_any_line_item
      if line_items.empty?
        return true
      else
        errors.add(:base, 'Line Items present')
        return false
      end
    end
end
