class AddStatusToCases < ActiveRecord::Migration[7.2]
  def change
    add_column :cases, :status, :string
  end
end
