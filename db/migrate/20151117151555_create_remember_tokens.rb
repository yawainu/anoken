class CreateRememberTokens < ActiveRecord::Migration
  def change
    create_table :remember_tokens do |t|
      t.integer :member_id, null: false
      t.string :browser, null: false
      t.string :platform, null: false
      t.string :token, null: false

      t.timestamps null: false
    end
    add_index :remember_tokens, :token, unique: true
    add_index :remember_tokens, [:member_id, :browser, :platform], unique: true
  end
end
