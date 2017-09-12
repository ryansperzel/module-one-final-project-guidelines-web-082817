class CreateBettors < ActiveRecord::Migration[4.2]
  def change
    create_table :bettors do |t|
      t.string :name
      t.integer :tokens
    end
  end
end
