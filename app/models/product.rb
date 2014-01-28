class Product < ActiveRecord::Base
  attr_accessible :code, :description, :featured, :name, :name_prefix, :on_promotion, :price, :product_brand_id, :product_category_id, :product_type_id, :promotion_days, :quantity, :release_year, :sales, :top_10, :unit_vat, :views

  # Building relationships between models
  belongs_to :product_type
  belongs_to :product_category
  belongs_to :product_brand
  has_many :customer_orders, :through => :line_items
  has_many :line_items, :dependent => :destroy

  # Validations
  validates :code, :presence => true
  validates :name, :presence => true

  PRODUCTS_ALPHABET = [
  # Displayed stored in db
  ["ALL" , "all" ],
  ["A - C" , "a-c" ],
  ["D - F" , "d-f" ],
  ["G - I" , "g-i" ],
  ["J - L" , "j-l" ],
  ["M - N" , "m-n" ],
  ["O - Q" , "o-q" ],
  ["R - T" , "r-t" ],
  ["U - W" , "u-w" ],
  ["X - Z" , "x-z" ]
  ]
 
  def self.products_for_sale
    find(
      :all,
      :order => 'name',
      :conditions => 'quantity >= 2 AND featured = 0 AND top_10 = 0',
      :limit => 25
    )
  end

  def self.top_ten_products
    find_all_by_top_10(
      true,
      :conditions => 'quantity >= 2',
      :order => 'name', :limit => 10
    )
  end

  def self.featured_products
    find_all_by_featured(
      true,
      :conditions => 'quantity >= 2',
      :order => 'name', :limit => 12
    )
  end

  def self.products_by_category(category)
    find_all_by_product_category_id(
      category,
      :conditions => 'quantity >= 2',
      :order => 'name'
    )
  end

  def self.products_on_promotion
  end

  def product_sales
    @orders = self.orders
    @orders.count
  end

  def number_of_sales
    @items = self.line_items
    sales = 0
    for i in @items
      sales += i.quantity
    end
    sales
  end


  # Protected or private methods
  protected
    def price_must_be_at_least_a_cent
    errors.add(:price, 'should be at least 0.01' ) if price.nil? || price < 0.01
    end

end
