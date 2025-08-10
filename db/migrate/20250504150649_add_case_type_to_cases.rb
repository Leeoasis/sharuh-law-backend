class AddCaseTypeToCases < ActiveRecord::Migration[7.2]
  def change
    add_column :cases, :case_type, :string
  end
end
