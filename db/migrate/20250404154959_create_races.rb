class CreateRaces < ActiveRecord::Migration[8.0]
  def change
    create_table :races do |t|
      t.string :slug, null: false
      t.string :status, null: false, default: "pending"
      t.text :body, null: false
      t.integer :duration_in_seconds
      t.datetime :started_at
      t.integer :host_id, null: false

      t.timestamps
    end
  end
end
