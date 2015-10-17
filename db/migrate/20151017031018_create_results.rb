class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.string :challenger, limit: 3, null: false, default: "ANO"
      t.integer :score, null: false, default: 0

      t.timestamps null: false
    end
  end
end
