class SurvivorsController < ApplicationController
  before_action :find_survivor, only: [:show, :update, :destroy, :flag_survivor]

  # Controller constants definition
  # FIELDS defined as a means of keeping track of which values are actual fields
  # in the survivor's model
  FIELDS = ["id", "name", "age", "gender", "latitude", "longitude", "number_of_flags",
            "is_abducted", "created_at", "updated_at"]

  # Both params are defined to highlight all the normal/valid parameters to be
  # forwarded during their respective actions
  CREATE_PARAMS = ["name", "age", "gender", "latitude", "longitude", "survivor", 
                  "id", "controller", "action"]
  UPDATE_PARAMS = ["latitude", "longitude", "survivor", "id", "controller", "action"]

  # GET /survivors
  # Can be specified a parameter 'fields' to show only specific parameters
  # Defaults to all fields otherwise
  # Example: /survivors?fields=id,name,age
  # If 'name' is in the query, orders alphabetically with respects to 'name'
  def index
    fields = params['fields'] ? sanitize_fields_params(params['fields']) : "*"
    fields = fields.empty? ? "*" : fields
    survivors = Survivor.select(fields).order(:name)
    render json: survivors
  end

  # GET /survivors/:id
  def show
    render json: @survivor
  end

  # POST /survivors
  # Warns the user if any parameter forwarded is unnecessary
  def create
    @survivor = Survivor.new(create_survivor_params)
    message_hash = {}
    warning = create_unused_params_warning(SurvivorsController::CREATE_PARAMS, params)
    message_hash = message_hash.merge(warning)
    if @survivor.save
      message_hash["message"] = "Survivor created"
      message_hash["survivor"] = @survivor
      json_message(message_hash, :created)
    else
      message_hash["error"] = "Error during creation process! Verify your parameters " +
                              "and try again (Tip: 'gender', currently, can only be set as 'male' or 'female')"
      json_message(message_hash, :internal_server_error)
    end
  end

  # PUT/PATCH /survivors/:id
  # Updates only a survivor's 'latitude' or 'longitude'
  def update
    message_hash = {}
    warning = create_unused_params_warning(SurvivorsController::UPDATE_PARAMS, params)
    message_hash = message_hash.merge(warning)
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

  # DELETE /survivors/:id
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

  # GET /survivors/:id/flag
  # Renders different messages to the user depending of the specified survivor state
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

  # GET /survivors/statistics
  # Renders message contain percentual of abducted and non-abucted individuals
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

  # Cleans parameter 'fields' of any element not found in SurvivorsController::FIELDS
  def sanitize_fields_params(fields)
    valid_fields = []
    fields.split(',').each do |field|
      if SurvivorsController::FIELDS.include?(field)
        valid_fields.push(field)
      end
    end
    valid_fields
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

  def create_unused_params_warning(valid_params, in_use_params)
    message = {}
    invalid_params = get_invalid_parameters(valid_params, in_use_params)
    if !invalid_params.empty?
      message["warning"] = "Unnecessary/unused parameters sent: " + invalid_params.join(', ')
    end
    return message
  end

  # Verifies if a value for latitude or longitude was passed and
  # updates survivor's fields accordingly
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
