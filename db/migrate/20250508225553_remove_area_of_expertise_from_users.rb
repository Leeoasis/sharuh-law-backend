class RemoveAreaOfExpertiseFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :area_of_expertise, :string
  end
end
