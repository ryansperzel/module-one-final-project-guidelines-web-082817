class AddTokensToBettors < ActiveRecord::Migration[4.2]
  def change
    add_column :teams, :tokens, :integer
  end
end
