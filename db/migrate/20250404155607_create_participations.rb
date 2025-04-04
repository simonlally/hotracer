class CreateParticipations < ActiveRecord::Migration[8.0]
  def change
    create_table :participations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :race, null: false, foreign_key: true
      t.integer :words_per_minute
      t.integer :accuracy
      t.integer :placed
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
  end
end
