class CreateCreations < ActiveRecord::Migration[5.2]
  def change
    create_table :creations do |t|
      t.references :user, foreign_key: true
      t.references :kanji, foreign_key: true
    end
  end
end
