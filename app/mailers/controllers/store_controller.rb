class StoreController < ApplicationController
  before_filter :find_cart, :except => [:empty_cart]
  def index
    @products = Product.products_for_sale
    @featured_products = Product.featured_products
    @top_ten_products = Product.top_ten_products
  end

  def add_to_cart
    product = Product.find(params[:id])
    @current_item = @cart.add_product(product)
      respond_to do |format|
#      format.js if request.xhr?
      format.html {redirect_to_index}
      end
#    rescue ActiveRecord::RecordNotFound
#    logger.error("Attempt to access invalid product #{params[:id]}" )
#    redirect_to_index("Invalid product" )
  end

  def empty_cart
    session[:cart] = nil
    redirect_to_index
  end

  def checkout
    if @cart.items.empty?
      redirect_to_index("Your cart is empty!")
    else
      @order = CustomerOrder.new
    end
  end

  private

  def find_cart
    @cart = (session[:cart] ||= Cart.new)
  end

  def menu_items
    @menu_categories = Category.find(:all)
  end

  def redirect_to_index(msg = nil)
    flash[:notice] = msg if msg
    redirect_to :action => 'index'
  end

  # The above method can also be written as

  #  def find_cart
  #    session[:cart] ||= Cart.new
  #  end

end
