class MakeUserEmailCitext < ActiveRecord::Migration[4.2]
  def change
    enable_extension 'citext'
    change_column :users, :email_address, :citext
  end
end
