class AddCourtToCases < ActiveRecord::Migration[7.2]
  def change
    add_column :cases, :court, :string
  end
end
