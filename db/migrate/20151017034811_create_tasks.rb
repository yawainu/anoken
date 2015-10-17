class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name, null: false, limit: 100
      t.integer :state, null: false, default: 0
      t.boolean :touched, null: false, default: false
      t.integer :category, null: false
      t.integer :priority, null: false
      t.integer :result_id, null: false
      t.text :comment, limit: 5000

      t.timestamps null: false
    end
    add_index :tasks, :result_id
  end
end
