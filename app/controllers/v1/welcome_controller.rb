module V1
  class WelcomeController < ApplicationController
    # GET root
    # Displays a welcome message alongside a brief description of all the API's endpoints
    def index
      render json: {
                      message:"Welcome to XS-UNIT's API, this API was developed to aid in humanity's survival.",
                      endpoints:{
                              "GET /survivors": "Returns a JSON list of all survivors ordered alphabetically. Return Status Code 200 OK",
                              "POST /survivors": "By passing a JSON with all the necessary information of a survivor(name, age, gender and current latitude, longitude) a new survivor is created. Returns Status Code 204 Created",
                              "GET /survivors/:id": "Returns a JSON of all the information of the survivor with id :id. Returns Status Code 200 OK",
                          }
                }
    end
  end
end
