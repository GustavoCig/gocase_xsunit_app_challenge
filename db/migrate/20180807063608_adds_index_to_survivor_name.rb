class AddsIndexToSurvivorName < ActiveRecord::Migration[5.2]
  def change
    add_index :survivors, :name, :unique => true
  end
end
