class SurvivorsController < ApplicationController
  before_action :find_survivor, only: [:show, :update, :destroy, :flag_survivor]

  def index
    survivors = Survivor.all.order(:name)
    render json: survivors
  end

  def show
    render json: @survivor
  end

  def create
    @survivor = Survivor.new(create_survivor_params)
    message_hash = {}
    valid_params = ["name", "age", "gender", "latitude", "longitude" "survivor", 
                    "id", "controller", "action"]
    invalid_params = get_invalid_parameters(valid_params, params)
    message_hash["warning"] = create_unused_params_warning(invalid_params)
    if @survivor.save
      message_hash["message"] = "Survivor created"
      message_hash["survivor"] = @survivor
      json_message(message_hash, :created)
    else
      message_hash["error"] = "Error during creation process!"
      json_message(message_hash, :internal_server_error)
    end
  end

  def update
    message_hash = {}
    valid_params = ["latitude", "longitude", "survivor", "id", "controller", "action"]
    invalid_params = get_invalid_parameters(valid_params, params)
    message_hash["warning"] = create_unused_params_warning(invalid_params)
    old_latitude = @survivor.latitude
    old_longitude = @survivor.longitude
    update_survivor_location(@survivor, params["latitude"], params["longitude"])
    if @survivor.update(update_location_params)
      message_hash["message"] = "Survivor " + @survivor.name + " location updated: " + 
                                "Latitude(" + old_latitude.to_s + " => " + @survivor.latitude.to_s + "), " +
                                "Longitude(" + old_longitude.to_s + " => " + @survivor.longitude.to_s + ")"
      json_message(message_hash)
    else
      message_hash["error"] = "Error during location update process!"
      json_message(message_hash, :internal_server_error)
    end
  end

  def destroy
    message_hash = {}
    if @survivor.destroy
      message_hash["message"] = "Survivor " + @survivor.name + " - ID: " + @survivor.id.to_s + " has been deleted"
      json_message(message_hash)
    else
      message_hash["error"] = "Error during deletion process!"
      json_message(message_hash, :internal_server_error)
    end
  end

  def flag_survivor
    @survivor = Survivor.find(params[:id])
    message_hash = {}
    if @survivor.is_abducted
      message_hash["message"] = "Survivor " + @survivor.name + " already been abducted!"
      message_hash["survivor"] = @survivor
      json_message(message_hash)
    else
      increment_survivor_flags(@survivor)
      update_survivor_status(@survivor)

      message = "Survivor " + @survivor.name
      message += @survivor.is_abducted ? " has been abducted" : " is still safe..."
      message += ", flagged " + @survivor.number_of_flags.to_s + " time(s)"
      message_hash["message"] = message
      message_hash["survivor"] = @survivor

      if @survivor.update(flagging_params)
        json_message(message_hash)
      else
        message_hash["error"] = "Error during survivor's parameters update!"
        json_message(message_hash, :internal_server_error)
      end
    end
  end

  def show_survivors_statistics
    message_hash = {}
    number_of_abductees = Survivor.where(is_abducted: true).count()
    number_of_survivors = Survivor.all.count()
    percentage_of_abductees = calculate_percentage(number_of_abductees, number_of_survivors)
    percentage_of_safe_survivors = 100 - percentage_of_abductees
    message_hash["percentage of abductees"] =  percentage_of_abductees.to_s + "%"
    message_hash["percentage of safe survivors"] = percentage_of_safe_survivors.to_s + "%"
    json_message(message_hash)
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

  def get_invalid_parameters(valid_parameters, parameters)
    invalid_parameters = []
    parameters.each do |key, value|
      if !valid_parameters.include?(key)
        invalid_parameters.push(key)
      end
    end
    return invalid_parameters
  end

  def create_unused_params_warning(invalid_params)
    if !invalid_params.empty?
      "Unnecessary/unused parameters sent: " + invalid_params.join(', ')
    end
  end

  def update_survivor_location(survivor, latitude=false, longitude=false)
    survivor.latitude = (latitude) ? latitude : survivor.latitude
    survivor.longitude = (longitude) ? longitude : survivor.longitude
  end

  def increment_survivor_flags(survivor)
    survivor.number_of_flags += 1
  end

  def update_survivor_status(survivor)
    if survivor.number_of_flags >= 3
      survivor.is_abducted = true
    end
  end

  def calculate_percentage(value, total)
    (value*100)/total
  end

  def find_survivor
    @survivor = Survivor.find(params[:id])
  end
end
