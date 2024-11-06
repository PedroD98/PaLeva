class MenusController < ApplicationController
  before_action :authenticate_user!
  before_action :user_has_registered_restaurant?
  before_action :set_restaurant_and_items
  before_action :validate_user
  before_action :set_menu, only: [:edit, :update, :show]
  before_action :set_dishes_and_beverages, only: [:edit, :update, :show]

  def index
    @menus = @restaurant.menus
  end

  def new
    @menu = Menu.new
  end

  def create
    @menu = @restaurant.menus.create(menu_params)

    if @menu.save
      redirect_to restaurant_menu_path(@restaurant, @menu), notice: 'Cardápio cadastrado com sucesso!'

    else
      flash.now[:alert] = 'Falha ao cadastrar cardápio.'
      render 'new', status: :unprocessable_entity
    end
    
  end

  def edit
  end

  def update
    if handle_item_ids
      redirect_to restaurant_menu_path(@restaurant, @menu), notice: 'Itens adicionados com sucesso!'
      
    else
      set_dishes_and_beverages
      flash.now[:alert] = 'Falha ao adicionar itens.'
      render 'edit', status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def set_restaurant_and_items
    @restaurant = Restaurant.find(params[:restaurant_id])
    @items = @restaurant.items
  end

  def set_dishes_and_beverages
    @dishes = @restaurant.items.where(type: 'Dish').where.not(id: @menu.items.pluck(:id))
    @beverages = @restaurant.items.where(type: 'Beverage').where.not(id: @menu.items.pluck(:id))
  end

  def validate_user
    if @restaurant != current_user.restaurant
      redirect_to restaurant_path(current_user.restaurant), alert: 'Você não pode acessar essa página.'
    end
  end

  def menu_params
    params.require(:menu).permit(:name, item_ids: [])
  end

  def handle_item_ids
    item_ids_params = params[:menu][:item_ids].reject(&:blank?)
    selected_items = @items.where(id: item_ids_params)

    selected_items.each do |item|
      @menu.items << item
    end
  end
end