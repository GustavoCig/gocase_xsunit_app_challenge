class AddsDefaultValueToIsAbducted < ActiveRecord::Migration[5.2]
  def change
    change_column_default :survivors, :is_abducted, 0
  end
end
