class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.integer :project_id, null: false
      t.string :codename, limit: 50, null: false
      t.string :password_digest, null: false

      t.timestamps null: false
    end
    add_index :members, :codename, unique: true
  end
end
