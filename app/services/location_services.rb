class Location_services

  def save_current_location(survivor)
    location = {}
    location["latitude"] = survivor.latitude
    location["longitude"] = survivor.longitude
    return location
  end

  # Verifies if a value for latitude or longitude was passed and
  # updates survivor's fields accordingly
  def update_survivor_location(survivor, latitude=false, longitude=false)
    survivor.latitude = (latitude) ? latitude : survivor.latitude
    survivor.longitude = (longitude) ? longitude : survivor.longitude
  end

end