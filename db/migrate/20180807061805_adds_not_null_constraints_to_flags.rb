class AddsNotNullConstraintsToFlags < ActiveRecord::Migration[5.2]
  def change
    change_column_null :survivors, :number_of_flags, false, 0
  end
end
