class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :user_has_registered_restaurant?
  before_action :set_restaurant
  before_action :is_restaurant_open?, only: [:new, :create, :confirming,
                                             :preparing, :done, :delivered]
  before_action :restaurant_has_order_in_creation?, only: [:new, :create]
  before_action :set_order_and_validate_user, only: [:show, :confirming, :preparing,
                                                     :done, :delivered, :canceled]
  before_action :order_has_items?, only: [:confirming, :preparing, :done, :delivered]


  def index
    @orders = @restaurant.orders
  end

  def new
    @order = Order.new
  end

  def create
    @order = @restaurant.orders.create(order_params)

    if @order.save
      redirect_to @order,
      notice: 'Pedido criado com sucesso!'
    else
      flash.now[:alert] = 'Falha em criar pedido.'
      render 'new', status: :unprocessable_entity
    end
  end

  def show; end

  def confirming
    @order.confirming!
    @order.create_discount_orders
    @order.calculate_order_totals
    redirect_to @order, notice: 'Pedido enviado para a cozinha.'
  end

  def preparing
    @order.preparing!
    @order.update(preparing_timestamp: Time.current)
    redirect_to @order, notice: 'Pedido foi confirmado e está sendo preparado.'
  end

  def done
    @order.done!
    @order.update(done_timestamp: Time.current)
    redirect_to @order, notice: 'Pedido pronto para a entrega.'
  end

  def delivered
    @order.delivered!
    @order.update(delivered_timestamp: Time.current)
    redirect_to @order, notice: 'Pedido entregue com sucesso.'
  end

  def canceled
    @order.canceled!
    @order.update(cancel_reason: params[:cancel_reason]) if params[:cancel_reason]
    redirect_to @order, alert: 'Pedido cancelado.'
  end

  private

  def set_restaurant
    @restaurant = current_user.restaurant
    @restaurant.update_operation_status
  end

  def set_order_and_validate_user
    @order = Order.find(params[:id])
    if @order.restaurant != current_user.restaurant
      redirect_to root_path, alert: 'Você não pode acessar essa página.' 
    end
  end

  def order_has_items?
    if @order.order_portions.empty?
      redirect_to @order, alert: 'Essa ação só pode ser realizada se o pedido não estiver vazio.'
    end
  end

  def is_restaurant_open?
    if @restaurant.closed?
      redirect_to orders_path, alert: 'O restaurante está fechado no momento.'
    end
  end
  
  def restaurant_has_order_in_creation?
    @order_in_creation = @restaurant.orders.find_by(status: :creating)
    redirect_to orders_path, 
      alert: 'É permitido ter apenas um pedido com status: Em criação.' if @order_in_creation
  end

  # def create_discount_order
  #   @order.order_portions.each do |order_portion|

  #     if order_portion.discount
  #       discount_order = DiscountOrder.find_by(order: @order , discount_id: order_portion.discount)

  #       unless discount_order
  #         @order.discount_orders.create(discount: order_portion.discount)
  #       end
  #     end
  #   end
  # end

  def order_params
    params.require(:order).permit(:customer_name, :customer_phone, :customer_email,
                                  :customer_social_number, :cancel_reason)
  end
end