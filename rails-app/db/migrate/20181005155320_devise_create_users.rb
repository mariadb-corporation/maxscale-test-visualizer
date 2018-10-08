# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      ## OAuth
      t.string :uid
      t.string :provider

      t.string :name
      t.string :image
      t.string :nickname

      t.timestamps null: false
    end
  end
end
