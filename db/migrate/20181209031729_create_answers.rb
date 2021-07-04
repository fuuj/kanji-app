class CreateAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :answers do |t|
      t.references :creation, foreign_key: true
      t.integer :correct
    end
  end
end
