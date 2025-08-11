# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Additional Fields
      t.string :name
      t.string :role, null: false, default: "client"
      t.string :phone_number
      # t.string :profile_picture
      t.text :address

      # Lawyer-specific fields
      t.string :license_number
      t.text :area_of_expertise
      t.integer :experience_years
      # t.text :bio
      # t.string :languages, array: true, default: []
      t.decimal :rate
      # t.text :office_address
      t.string :preffered_court
      # t.float :average_rating, default: 0.0
      # t.integer :review_count, default: 0
      # t.text :certifications
      # t.boolean :verification_status, default: false
      # t.string :portfolio_url

      # Client-specific fields
      t.string :preferred_language
      t.string :budget
      # t.string :case_type
      # t.integer :current_case_id

      # System-level fields
      t.datetime :last_login_at
      t.datetime :last_activity_at
      t.string :status, default: "active"

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token, unique: true
    # add_index :users, :unlock_token, unique: true
  end
end
