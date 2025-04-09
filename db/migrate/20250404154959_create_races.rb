class CreateRaces < ActiveRecord::Migration[8.0]
  def change
    create_table :races do |t|
      t.string :slug, null: false
      t.string :status, null: false, default: "pending"
      t.text :body, null: false
      t.references :host, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :races, :slug, unique: true
  end
end
