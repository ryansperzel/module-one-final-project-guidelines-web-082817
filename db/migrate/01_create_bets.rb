class CreateBets < ActiveRecord::Migration[4.2]
  def change
    create_table :bets do |t|
      t.integer :bettor_id
      t.integer :team_id
      t.intger :amount
    end
  end
end
