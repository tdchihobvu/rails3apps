class StoreController < ApplicationController
  before_filter :authorize, :only => [:checkout]
#  before_filter :sweep
  before_filter :find_cart, :except => [:empty_cart]
  before_filter :menu_items, :except => [:empty_cart]

  def sign_in
    @published_comments = Comment.published_comments
  end

  def login
       if request.post?
         user = User.authenticate(params[:random_pass], params[:mobile_number])
         unless user.nil?
         # check if the user's authenticity token is still valid
         unless user.updated_at < "#{5.days.ago.to_s(:db)}"
            if user
            reset_session
            session[:user_id] = user.id
            user.update_attribute(:updated_at, Time.now)
            redirect_to(:controller => 'store', :action => 'checkout' )
            else
            flash[:notice] = "Invalid access token entered."
            redirect_to(:controller => 'store', :action => 'sign_in' )
            end
         else
           flash[:notice] = "Your access token has expired you need to sign up for a new acess token."
           redirect_to(:controller => 'store', :action => 'sign_in' )
         end
         # end checking the validity of user's authenticity token
         else
           flash[:notice] = "Invalid access token entered."
           redirect_to(:controller => 'store', :action => 'sign_in' )
         end
       end
  end

  def search_ajax
    @products = Product.products_for_sale
    @product = Product.find(:all,
      :conditions => "(name LIKE \"#{params[:query]}%\"
      OR description LIKE \"#{params[:query]}%\"
      OR code LIKE \"#{params[:query]}%\")",
      :order => "name asc") unless params[:query] == ''
      params[:id].nil?
      unless @product.nil?
      @search_count = @product.count
      end
    render :layout => false
  end

  def index
    @products = Product.products_for_sale
    @featured_products = Product.featured_products
    @top_ten_products = Product.top_ten_products
    @published_comments = Comment.published_comments
  end

  def testajax
    puts("tiri tiiiiiiiiiiiiiii mhani iwe")
    @products = Product.all
    @products.each do |p|
      puts("dealing with #{p.name}")
#      p.update_attribute(:name_prefix, p.name.first)
    end
  end

  def products_atoz
    puts("tiri tiiiiiiiiiiiiiii mhani iwe")
  end

  def products_by_alphabet
    range = params[:id]
    puts(range)
    if range == "all"
      @products_by_alphabet = Product.find(:all, :order => 'name Asc')
    elsif range == "a-c"
      puts("All products with letter a to c")
      @products_by_alphabet = Product.find(:all, :conditions => "name_prefix = 'a' or name_prefix = 'b' or name_prefix = 'c' ", :order => "name_prefix ASC")
    elsif range == "d-f"
      puts("All products with letter d to f")
      @products_by_alphabet = Product.find(:all, :conditions => "name_prefix = 'd' or name_prefix = 'e' or name_prefix = 'f' ", :order => "name_prefix ASC")
    elsif range == "g-i"
      puts("All products with letter g to i")
      @products_by_alphabet = Product.find(:all, :conditions => "name_prefix = 'g' or name_prefix = 'h' or name_prefix = 'i' ", :order => "name_prefix ASC")
    elsif range == "j-l"
      puts("All products with letter j to l")
      @products_by_alphabet = Product.find(:all, :conditions => "name_prefix = 'j' or name_prefix = 'k' or name_prefix = 'l'", :order => "name_prefix ASC")
    elsif range == "m-n"
      puts("All products with letter m to n")
      @products_by_alphabet = Product.find(:all, :conditions => "name_prefix = 'm' or name_prefix = 'n'", :order => "name_prefix ASC")
    elsif range == "o-q"
      puts("All products with letter o to q")
      @products_by_alphabet = Product.find(:all, :conditions => "name_prefix = 'o' or name_prefix = 'p' or name_prefix = 'q'", :order => "name_prefix ASC")
    elsif range == "r-t"
      puts("All products with letter r to t")
      @products_by_alphabet = Product.find(:all, :conditions => "name_prefix = 'r' or name_prefix = 's' or name_prefix = 't'", :order => "name_prefix ASC")
    elsif range == "u-w"
      puts("All products with letter u to w")
      @products_by_alphabet = Product.find(:all, :conditions => "name_prefix = 'u' or name_prefix = 'v' or name_prefix = 'w'", :order => "name_prefix ASC")
    elsif range == "x-z"
      puts("All products with letter x to z")
      @products_by_alphabet = Product.find(:all, :conditions => "name_prefix = 'x' or name_prefix = 'y' or name_prefix = ''", :order => "name_prefix ASC")
    end
      @cat_name = range
      @count = @products_by_alphabet.count
      respond_to do |format|
      format.js
      end
  end

  def add_to_cart
    puts("tapinda baba")
    product = Product.find(params[:id])
    @current_item = @cart.add_product(product)
      respond_to do |format|
      format.js if request.xhr?
      end
    rescue ActiveRecord::RecordNotFound
    logger.error("Attempt to access invalid product #{params[:id]}" )
    redirect_to_index("Invalid product" )
  end

  def empty_cart
    session[:cart] = nil
    redirect_to_index
  end

  def checkout
    @published_comments = Comment.published_comments
    if @cart.items.empty?
      redirect_to_index("Your cart is empty!")
    else
      @customer_order = CustomerOrder.new
    end
  end

  def save_order
    @published_comments = Comment.published_comments
    @user = current_user
    @customer_order = CustomerOrder.new(params[:customer_order])
    @today = Date.today
    d = @today.day
    m = @today.month
    y = @today.strftime("%y")
    last_order = CustomerOrder.find(:last)

    if last_order.nil?
      @customer_order.order_no = "ORD0001"
    else
      @customer_order.order_no = last_order.order_no.next
    end
    @customer_order.posted_on = Date.today
    @customer_order.add_line_items_from_cart(@cart)
    if @customer_order.save
      order = @customer_order
      OrderMailer.order_email(order).deliver
      @customer_order.reduce_quantity_sold(@customer_order)
      session[:cart] = nil
      redirect_to_index("Thank you for your order, a message has been sent to your mobile confirming your Order Number #{@customer_order.order_no.last(4)}")
    else
      render :action => 'checkout'
    end
    rescue SocketError
      logger.error("Email Failure: Error occured whilst trying to send an email for order number #{@customer_order.order_no.last(4)}.")
      redirect_to_index("Sorry your order could not be sent, an error occured whilst sending the order.")
  end

  def customer_requests
    puts("tiri tiiiiiiiiiiiiiii mhani iwe irequest heavy")
    @customer_request = UserRequest.new
  end

  def save_request
    @customer_request = UserRequest.new(params[:customer_request])
    if @customer_request.save
      if @customer_request.notify_me?
      redirect_to_index("Thank you for your request. You will be notified as soon as we meet your request.")
      else
      redirect_to_index("Thank you for your request.")
      end
    else
      redirect_to_index("Your request could not be sent, make sure you fill all fields correctly.")
    end
  end

  def comments
    puts("tiri tiiiiiiiiiiiiiii mhani iwe irequest heavy")
    @comment = Comment.new
  end

  def save_comment
    @comment = Comment.new(params[:comment])
    if @comment.save
      redirect_to_index("Thank you for your comment.")
    else
      redirect_to_index("Your comment could not be sent, make sure you fill all fields correctly.")
    end
  end

  def category_items
    category = ProductCategory.find(params[:id])
    @category_items = Product.products_by_category(category)
    @cat_name = category.name
    @count = @category_items.count
#    respond_to do |format|
#      format.js if request.xhr?
#      format.html
#      end
    rescue ActiveRecord::RecordNotFound
    logger.error("Attempt to access invalid menu item #{params[:id]}" )
    redirect_to_index("Invalid Menu Item" )
  end

  def activate_account
    @user = User.find_by_phone_number(params[:id])
    @published_comments = Comment.published_comments
    rescue ActiveRecord::RecordNotFound
    logger.error("Attempt to have unauthorised" )
    redirect_to_index("Invalid access code" )
  end

  def activate
    @user = User.find_by_phone_number(params[:id])
    unless @user.nil?
    user_code = @user.phone_number
    if @user.random_pass == params[:random_pass]
      User.activate_user_account(user_code)
      flash[:notice] = "Your account has been successfully activated, you can log in"
      redirect_to :action => 'checkout'
    else
      flash[:notice] = "You have entered an invalid access code."
      redirect_to :action => 'activate_account', :id => @user.phone_number
    end
    end
  end

  def renew_account
    @published_comments = Comment.published_comments
  end

  def activate_renewal
    if request.post?
    unless params[:email].empty? || params[:mobile_number].empty?
      email = params[:email]
      mobile = params[:mobile_number]
      user = User.renew_access_token(email, mobile)
      if user
        new_pass = User.generate_activation_code
        user.update_attribute(:random_pass, new_pass)
        usr = user.id
        UserEmail.user_renewal(usr).deliver
        flash[:notice] = "Your new access code has been sent to your email."
        redirect_to(:controller => 'store', :action => 'sign_in' )
        else
        flash[:notice] = "Invalid access token entered."
        redirect_to(:controller => 'store', :action => 'sign_in' )
      end
    else
      flash[:notice] = 'Please verify your information, some fields are missing'
      redirect_to :action => 'renew_account'
    end
    end
    rescue SocketError
      logger.error("Email Failure: Error occured whilst trying to send an email for access code #{user.name}.")
      redirect_to_index('Your new access code has been sent to your email.')
  end

  def new_user
    @published_comments = Comment.published_comments
    @new_user = User.new
    @num1 = @new_user.generate_first_number
    @num2 = @new_user.generate_second_number

  end

  def create_new_user
    @published_comments = Comment.published_comments
    @new_user = User.new(params[:new_user])
    @new_user.random_pass = User.generate_activation_code

      if @new_user.save
        user = @new_user.id
        UserEmail.user_email(user).deliver
        redirect_to_index('An access token and activation link has been sent to your email. Activate your account before you login.')
      else
         render :action => 'new_user'
      end
    rescue SocketError
      logger.error("Email Failure: Error occured whilst trying to send an email for access code #{@user.name}.")
      redirect_to_index('Error in connection. An error occured whilst trying to send you an email. ')
  end

  private

  def find_cart
    @cart = (session[:cart] ||= Cart.new)
  end

  def menu_items
    @menu_categories = ProductCategory.find(:all, :order => 'name')
  end

  def redirect_to_index(msg = nil)
    flash[:notice] = msg if msg
    redirect_to :action => 'index'
  end

  

end
