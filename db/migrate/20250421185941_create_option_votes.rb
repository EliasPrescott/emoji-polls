class CreateOptionVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :option_votes do |t|
      t.references :option, null: false, foreign_key: true
      t.references :poll, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
