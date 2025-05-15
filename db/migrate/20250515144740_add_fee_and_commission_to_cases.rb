class AddFeeAndCommissionToCases < ActiveRecord::Migration[7.2]
  def change
    add_column :cases, :fee, :decimal
    add_column :cases, :commission, :decimal
  end
end
