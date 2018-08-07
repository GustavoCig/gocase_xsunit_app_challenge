class AddsNotNullConstraintsToIsAbducted < ActiveRecord::Migration[5.2]
  def change
    change_column_null :survivors, :is_abducted, false, 0
  end
end
