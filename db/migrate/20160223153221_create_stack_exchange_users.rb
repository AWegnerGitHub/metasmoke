# frozen_string_literal: true

class CreateStackExchangeUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :stack_exchange_users do |t|
      t.integer :user_id
      t.string :username
      t.datetime :last_api_update
      t.boolean :still_alive, default: true
      t.integer :answer_count
      t.integer :question_count
      t.integer :reputation

      t.timestamps null: false
    end
  end
end
