class UpdateUserFieldsForAdmissionEnrollmentOrder < ActiveRecord::Migration[7.0]
  def change
    # Remove the old separate fields
    remove_column :users, :admission_order, :string
    remove_column :users, :enrollment_order, :string

    # Add the new combined field
    add_column :users, :admission_enrollment_order, :string
  end
end
