#encoding: utf-8
require 'paylane_client'
include PaymentsHelper
# Handles payments via Paylane vendor
# @see http://devzone.paylane.com/api-guide/
# @see http://devzone.paylane.com/api-guide/paylane-rest-client/
class PaymentsController < ApplicationController

  # Make payment request to Paylane
  def pay
    self.make 'sale' 
  end
  # Make authorization request to Paylane
  def authorize 
    self.make 'authorization' 
  end
  # Show summary info about order
  # @param id [String] Base64.encode`ed string. {Order#hash_id}
  def order_summary
    base_params = Rack::Utils.parse_nested_query(Base64.decode64(params[:id]))
    order_id = base_params["id"]
    @order = Order.find(order_id)
    response.status = :not_found and return if @order.user_id != current_user.id
  end
  # Show summary info about order
  # @param id [String] Base64.encode`ed string. {Order#hash_id}
  def order_callback
    base_params = Rack::Utils.parse_nested_query(Base64.decode64(params[:id]))
    order_id = base_params["id"]
    @order = Order.find(order_id)
    response.status = :not_found and return if @order.user_id != current_user.id

    salt        = Figaro.env.paylane_pass
    status      = params['status']
    description = params['description']
    amount      = params['amount']
    currency    = params['currency']
    hash        = params['hash']
    # set proper method depending on params name and last sale/auth id
    id = ''
    if params['id_sale'].present?
      id = params['id_sale']
      method = 'sale'
    else
      id = params['id_authorization']
      method = 'authorization'
    end 

    if status == 'ERROR'
      @order.last_sale_id = id
      @order.catch_error([:error][:error_reason => description])
      message = "Error, transaction declined, #{description}"
      redirect_to order_summary_path(I18n.locale, @order.hash_id), alert: message and return
    end
    #temporarty security off :/
    calc_hash = Digest::SHA1.hexdigest("#{salt}|#{status}|#{description}|#{amount}|#{currency}|#{id}")
    unless calc_hash == hash
      @order.set_state 3, method, id
      message = 'Declined due to security reasons.'
      redirect_to order_summary_path(I18n.locale, @order.hash_id), alert: message and return
    end
    if status == 'PERFORMED'
      @order.set_state 2, method, id
    end
    redirect_to order_summary_path(I18n.locale, @order.hash_id) and return
  end

  protected
  # Make request to Paylane with given method and payment type
  # @param method [STRING] Should be one of type: 'sale' or 'authorization'
  # @todo  Make me model method. Payment maybye? Refactor me!
  def make method
    if params.include?(:user)
      @payment_type_id = params[:user][:payment_type_id].to_i
      @form_url = @user.subscribed_to < Time.zone.now ? make_payment_path(I18n.locale) : make_authorization_path(I18n.locale)
      @method   = @user.subscribed_to ? 'sale' : 'authorization'
      case @payment_type_id
        when 1
          self.paypal method
        when 2..3
          self.card method
        else
          redirect_to request.referer, alert: t(:bad_payment, :scope => 'payments.errors') and return
      end
    else
      redirect_to request.referer, alert:  t(:no_payment, :scope => 'payments.errors')
    end
  end
  # Creates {PayLane::Client} new object. Sets proper price, message, and {Order} to {User}
  # @param method [STRING] Should be one of type: 'sale' or 'authorization'
  def load_client method
    @client = PayLane::Client.new(Figaro.env.paylane_user, Figaro.env.paylane_pass)
    price = method == 'sale'? @user.subscription_price : 1
    @success_message = method == 'sale'?
        t(:order_placed, :scope => 'payments.notices') :
        t(:payment_changed, :scope => 'payments.notices')
    @order  = Order.create(price: price, payment_id: @payment_type_id, subscription_id: @user.subscription_type_id )
    @order_url = order_summary_path(I18n.locale, @order.hash_id, :only_path => false)
    @user.orders << @order
  end
  # Send request with given payment type and method to Paylane and handle response.
  # @param method       [STRING] Should be one of type: 'sale' or 'authorization'
  # @param payment_type [STRING] Should be valid {PayLane::Client} payment method
  # @see http://devzone.paylane.com/api-guide/
  # @see PayLane::Client
  def send_paylane payment_type, method
    self.load_client method
    begin
      status = @client.send("#{payment_type}_#{method}", @payment.send("#{payment_type}_params", @order, request.remote_ip, @order_url))
    rescue PayLane::ClientError => e
      @order.catch_error({error: e.message})
    end
    if @client.success?
      state = payment_type == 'paypal' ? 1 : 2
      @order.set_state state, method, status["id_#{method}"]
      @user.update_attributes(payment_type_id: @payment_type_id) if @user.payment_type_id != @payment_type_id
      redirect_to payment_type == 'paypal' ? status['redirect_url'] : @order_url, notice: @success_message and return
    else
      status ||=  { error: {error_description: 'Internal server error.'}}
      @order.catch_error status
      redirect_to @order_url, alert: status[:error_description]
    end
  end
  # Creates new {Payment}. Make proper send_* method or show {Payment} validation errors
  # @param method [STRING] Should be one of type: 'sale' or 'authorization'
  # @todo  Make me model method. Payment maybye? Refactor me!
  def paypal method
    @payment = Payment.new(@user, 'paypal')
    if @payment.valid?
      send_paylane 'paypal', method
    else
      flash.alert = @payment.errors.to_a
      render "frontend/payment"
    end
  end
  # Creates new {Payment}. Make proper send_* method or show {Payment} validation errors
  # @param method [STRING] Should be one of type: 'sale' or 'authorization'
  # @todo  Make me model method. Payment maybye? Refactor me!
  def card method
    @payment = Payment.new(@user, 'card', params[:payment])
    if  @payment.valid?
      send_paylane 'card', method
    else
      flash.alert = @payment.errors.to_a
      render "frontend/payment"
    end
  end
end