class UserUidToString < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :uid
    add_column :users, :uid, :string
  end
end
