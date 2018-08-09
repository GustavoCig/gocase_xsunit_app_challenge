module V1
  class WelcomeController < ApplicationController
    # GET root
    # Displays a welcome message alongside a brief description of all the API's endpoints
    def index
      render json: {
        message:"Welcome to XS-UNIT's API, this API was developed to aid in humanity's survival.",
        endpoints:{
          "GET v1/survivors": "Returns a JSON list of all survivors ordered alphabetically.",
          "POST v1/survivors": "By passing a JSON with all the necessary information of a survivor(name, age, gender and current latitude, longitude) a new survivor is created.",
          "GET v1/survivors/:id": "Returns a JSON of all the information of the survivor with id :id.",
          "PATCH/UPDATE v1/survivors/:id": "Updates a survivor's latitude and longitude.",
          "DELETE v1/survivors/:id": "Deletes the survivor with the correspondent :id.",
          "GET v1/survivors/statistics": "Returns the percentual of abducted and non-abducted individuals",
          "GET v1/survivors/:id/flag": "Flags the user of the correspondent :id as 'abducted'"
        }
      }
    end
  end
end
