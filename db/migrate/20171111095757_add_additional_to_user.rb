class AddAdditionalToUser < ActiveRecord::Migration
  def change
    add_column :users, :times_introduced, :integer, default: 1
    add_column :users, :last_contacted, :datetime
    add_column :users, :last_contacted_by, :integer

  end
end
