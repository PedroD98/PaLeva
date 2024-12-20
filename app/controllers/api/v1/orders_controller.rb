class Api::V1::OrdersController < Api::V1::ApiController
  before_action :set_restaurant
  before_action :set_order_and_items, only: [:show, :update_to_preparing, :update_to_done,
                                             :update_to_canceled]

  def index
    @orders = Order.all.where(restaurant_id: @restaurant.id)
    filter_orders if params[:status_filters]
  end

  def show
    render status: 400, json: { message: 'O pedido está vazio'} if @order_portions.empty?
  end
  
  def update_to_preparing
    if validate_preparing_update
      @order.preparing!
      @order.update(preparing_timestamp: Time.current)
      render status: 200, json: { message: 'Status do pedido atualizado com sucesso' }
    else
      render status: 400, json: { errors: @order.errors.full_messages }
    end
  end

  def update_to_done
    if validate_done_update
      @order.done!
      @order.update(done_timestamp: Time.current)
      render status: 200, json: { message: 'Status do pedido atualizado com sucesso' }
    else
      render status: 400, json: { errors: @order.errors.full_messages }
    end
  end

  def update_to_canceled
    if validate_canceled_update
      @order.canceled!
      @order.update(cancel_reason: params[:cancel_reason]) if params[:cancel_reason]
      render status: 200, json: { message: 'Pedido cancelado' }
    else
      render status: 400, json: { errors: @order.errors.full_messages }
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find_by(code: params[:restaurant_code])
    render status: 404, json: { error: 'Restaurante não encontrado' } if @restaurant.nil?
  end

  def filter_orders
    @orders = @orders.where(status: params[:status_filters]) if validate_status_params
  end

  def validate_status_params
    params[:status_filters].each do |filter|
      return false unless Order.statuses.keys.include?(filter)
    end
  end

  def set_order_and_items
    @order = @restaurant.orders.find_by(code: params[:order_code])
    return render status: 404, json: { error: 'Pedido não encontrado' } if @order.nil?

    @order_portions = @order.order_portions
  end

  def validate_preparing_update
    if @order.confirming? && @order_portions.any?
      return true
    end

    @order.errors.add :base, 'Ação só pode ser feita em pedidos com status: Aguardando confirmação da cozinha' unless @order.confirming?
    @order.errors.add :base, 'Pedido não pode estar vazio' unless @order_portions.any?
    false
  end

  def validate_done_update
    return true  if @order.preparing?

    @order.errors.add :base, 'Ação só pode ser feita em pedidos com status: Em preparação'
    false
  end

  def validate_canceled_update
    return true  unless @order.delivered?

    @order.errors.add :base, 'Ação não pode ser feita em pedidos com status: Entregue'
    false
  end
end