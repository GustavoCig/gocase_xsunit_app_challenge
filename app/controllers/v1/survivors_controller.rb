module V1
  class SurvivorsController < ApplicationController
    before_action :find_survivor, only: [:show, :update, :destroy, :flag_survivor]

    # GET /survivors
    # Can be specified a parameter 'fields' to show only specific parameters,
    # a parameter 'per_page' to show a set amount of results per page,
    # a parameter 'page' to specify which set of results to show.
    # Example: /survivors?fields=id,name,age&per_page=5&page=3
    # If 'name' is in the query, orders alphabetically with respects to 'name'
    def index
      message_hash = {}
      message_hash = message_hash.merge(Params_reader.new.show_total_number_of_pages(params))
      message_hash["survivors"] = Params_reader.new.process_fields(params)
      json_message(message_hash)
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
      message_hash = message_hash.merge(Params_reader.new.unused_params_warning(Constants::CREATE_PARAMS, params))
      if @survivor.save
        message_hash["message"] = "Survivor created at /survivors/" + @survivor.id.to_s
        message_hash["survivor"] = @survivor
        json_message(message_hash, :created)
      else
        message_hash["error"] = "Error during creation process! Verify your parameters " +
                                "and try again (Tip: 'gender', currently, can only be set as 'male' or 'female')"
        message_hash["log"] = @survivor.errors
        json_message(message_hash, :internal_server_error)
      end
    end

    # PUT/PATCH /survivors/:id
    # Updates only a survivor's 'latitude' or 'longitude'
    def update
      message_hash = {}
      message_hash = message_hash.merge(Params_reader.new.unused_params_warning(Constants::UPDATE_PARAMS, params))
      old_location = Location_services.new.save_current_location(@survivor)
      Location_services.new.update_survivor_location(@survivor, params["latitude"], params["longitude"])
      if @survivor.update(update_location_params)
        message_hash["message"] = "Survivor " + @survivor.name + " location updated: " + 
                                  "Latitude(" + old_location["latitude"].to_s + " => " + @survivor.latitude.to_s + "), " +
                                  "Longitude(" + old_location["longitude"].to_s + " => " + @survivor.longitude.to_s + ")"
        json_message(message_hash)
      else
        message_hash["error"] = "Error during location update process!"
        message_hash["log"] = @survivor.errors
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
        message_hash["log"] = @survivor.errors
        json_message(message_hash, :internal_server_error)
      end
    end

    # GET /survivors/:id/flag
    # Renders different messages to the user depending of the specified survivor state
    def flag_survivor
      message_hash = {}
      if @survivor.is_abducted
        message_hash["message"] = "Survivor " + @survivor.name + " already been abducted!"
        message_hash["survivor"] = @survivor
        json_message(message_hash)
      else
        Flag_service.new.increment_survivor_flags(@survivor)
        Flag_service.new.update_survivor_status(@survivor)
        message_hash["message"] = "Survivor " + @survivor.name
        message_hash["message"] += @survivor.is_abducted ? " has been abducted" : " is still safe..."
        message_hash["message"] += ", flagged " + @survivor.number_of_flags.to_s + " time(s)"
        message_hash["survivor"] = @survivor
        if @survivor.update(flagging_params)
          json_message(message_hash)
        else
          message_hash["error"] = "Error during survivor's parameters update!"
          message_hash["log"] = @survivor.errors
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

    def calculate_percentage(value, total)
      (value*100)/total
    end

    def find_survivor
      begin
        @survivor = Survivor.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        message_hash = {}
        message_hash["error"] = "Survivor " + params[:id] + " not found," +
                                " please check your parameters and try again"
        json_message(message_hash, :not_found) 
      end
    end
    
  end
end