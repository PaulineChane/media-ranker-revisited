class RelateWorksToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :works, :user, index: true
  end
end
