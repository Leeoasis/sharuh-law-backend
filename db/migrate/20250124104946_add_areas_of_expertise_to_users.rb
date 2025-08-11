class AddAreasOfExpertiseToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :areas_of_expertise, :string
  end
end
