class MakeUserEmailCitext < ActiveRecord::Migration
  def change
    enable_extension 'citext'
    change_column :users, :email_address, :citext
  end
end
