class AddTokensToBettors < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :tokens, :integer
  end
end
