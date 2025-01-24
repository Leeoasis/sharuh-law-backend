class AddPreferredCourtToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :preferred_court, :string
  end
end
