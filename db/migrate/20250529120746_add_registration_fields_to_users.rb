class AddRegistrationFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    # Lawyer-specific fields
    add_column :users, :admission_order, :string
    add_column :users, :enrollment_order, :string
    add_column :users, :good_standing_letter, :string
    add_column :users, :fidelity_fund_certificate, :string
    add_column :users, :id_document, :string
    add_column :users, :practice_address, :string

    # Client-specific fields
    add_column :users, :engagement_form, :string
    add_column :users, :client_id_document, :string
    add_column :users, :client_proof_of_address, :string
  end
end
