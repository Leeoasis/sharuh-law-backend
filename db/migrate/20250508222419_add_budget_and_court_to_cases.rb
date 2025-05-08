class AddBudgetAndCourtToCases < ActiveRecord::Migration[7.2]
  def change
    add_column :cases, :budget, :integer
    add_column :cases, :court, :string
    add_column :cases, :case_type, :string
  end
end
