class AddsAutoIncrementToId < ActiveRecord::Migration[5.2]
  def change
    change_column :survivors, :id, :integer, limit: 8, auto_increment: true
  end
end
