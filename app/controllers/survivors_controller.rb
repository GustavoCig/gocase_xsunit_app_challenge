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
    message_hash = {}
    if @survivor.save
      message_hash["message"] = "Survivor created"
      message_hash["survivor"] = @survivor
      json_message(message_hash, :created)
    else
      message_hash["message"] = "Error during creation process!"
      json_message(message_hash, :bad_request)
    end
  end

  def update
  end

  def destroy
    message_hash = {}
    if @survivor.destroy
      message_hash["message"] = "Survivor " + @survivor.name + " - ID: " + @survivor.id + "has been deleted"
      json_message(message_hash)
    else
      message_hash["message"] = "Error during deletion process!"
      json_message(message_hash, :bad_request)
    end
  end

  def flag_survivor
    @survivor = Survivor.find(params[:id])
    message_hash = {}
    if @survivor.is_abducted
      message_hash["message"] = "Survivor " + @survivor.name + " already been abducted!"
      json_message(message_hash)
    else
      increment_survivor_flags(@survivor)
      update_survivor_status(@survivor)

      message = "Survivor " + @survivor.name
      message += @survivor.is_abducted ? " has been abducted" : " is still safe..."
      message += ", flagged " + @survivor.number_of_flags.to_s + " time(s)"
      message_hash["message"] = message

      if @survivor.update(flagging_params)
        json_message(message_hash)
      else
        message_hash["message"] = "Error during survivor's parameters update!"
        json_message(message_hash, :bad_request)
      end
    end
  end

  def show_percentage_abducted
  end

  private

  def json_message(message_hash, status=:ok)
    render json: message_hash.to_json, status: status
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
