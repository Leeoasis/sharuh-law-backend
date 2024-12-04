class CreateCases < ActiveRecord::Migration[6.1]
  def change
    create_table :cases do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.references :lawyer, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end