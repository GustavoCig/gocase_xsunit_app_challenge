class SurvivorsController < ApplicationController
  before_action :find_survivor, only: [:show, :destroy, :flag_survivor]

  def index
    survivors = Survivor.all
    render json: survivors
  end

  def show
    render json: @survivor
  end

  def new
    @survivor = Survivor.new
  end

  def edit
  end

  def create
    @survivor = Survivor.new(create_survivor_params)

    if @survivor.save
      render json: {
        message: "Survivor created",
        survivor: @survivor
      }
    else
      simple_json_message("Error during creation process!", :bad_request)
    end
  end

  def update
  end

  def destroy
    if @survivor.destroy
      simple_json_message("Survivor deleted successfully")
    else
      simple_json_message("Error during deletion process!", :bad_request)
    end
  end

  def flag_survivor
    @survivor = Survivor.find(params[:id])
    if @survivor.is_abducted
      simple_json_message("Survivor " + @survivor.name + " already been abducted!")
    else
      puts 'TESTE'
      puts @survivor.number_of_flags
      increment_survivor_flags(@survivor)
      puts @survivor.number_of_flags
      puts update_survivor_status(@survivor)

      message = "Survivor " + @survivor.name
      message += @survivor.is_abducted ? " has been abducted" : " is still safe..."
      message += ", flagged " + @survivor.number_of_flags.to_s + " time(s)"
      puts message
      
      if @survivor.update(flagging_params)
        simple_json_message(message)
      else
        simple_json_message("Error during survivor's parameters update!", :bad_request)
      end
    end
  end

  def show_percentage_abducted
  end

  private

  def simple_json_message(message, status=:ok)
    render json: {
      message: message
    }, status: status
  end

  def create_survivor_params
    params.require(:survivor).permit(:name, :age, :gender, :latitude, :longitude)
  end

  def update_location_params
    params.require(:survivor).permit(:latitude, :longitude)
  end

  def flagging_params
    params.fetch(:survivor, {}).permit(:number_of_flags, :is_abducted)
  end

  def increment_survivor_flags(survivor)
    survivor.number_of_flags += 1
  end

  def update_survivor_status(survivor)
    if survivor.number_of_flags >= 3
      survivor.is_abducted = true
    end
  end

  def find_survivor
    @survivor = Survivor.find(params[:id])
  end
end
