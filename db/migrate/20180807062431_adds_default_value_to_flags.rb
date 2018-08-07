class AddsDefaultValueToFlags < ActiveRecord::Migration[5.2]
  def change
    change_column_default :survivors, :number_of_flags, 0
  end
end
