class UserUidToBigint < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :uid, :bigint
  end
end
