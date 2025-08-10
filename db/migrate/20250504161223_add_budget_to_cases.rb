class AddBudgetToCases < ActiveRecord::Migration[7.2]
  def change
    add_column :cases, :budget, :string
  end
end
