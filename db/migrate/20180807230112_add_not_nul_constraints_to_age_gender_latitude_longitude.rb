class AddNotNulConstraintsToAgeGenderLatitudeLongitude < ActiveRecord::Migration[5.2]
  def change
    change_column_null :survivors, :age, false
    change_column_null :survivors, :gender, false
    change_column_null :survivors, :latitude, false
    change_column_null :survivors, :longitude, false
  end
end
