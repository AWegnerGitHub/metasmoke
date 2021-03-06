# frozen_string_literal: true

class AddUniqueConstraintToUsername < ActiveRecord::Migration[5.0]
  def change
    add_index :users, [:username], unique: true
  end
end
