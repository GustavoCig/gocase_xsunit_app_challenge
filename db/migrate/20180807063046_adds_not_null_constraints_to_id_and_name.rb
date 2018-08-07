class AddsNotNullConstraintsToIdAndName < ActiveRecord::Migration[5.2]
  def change
    change_column_null :survivors, :name, false
    change_column_null :survivors, :id, false
  end
end
