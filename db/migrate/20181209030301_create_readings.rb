class CreateReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :readings do |t|
      t.references :kanji, foreign_key: true
      t.string :reading
    end
  end
end
