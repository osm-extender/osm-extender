class RemoveEmailNFromEmailLists < ActiveRecord::Migration[4.2]
  def change
    change_table :email_lists do |t|
      t.remove :email1#, :boolean#, {default: false}
      t.remove :email2#, :boolean#, {default: false}
      t.remove :email3#, :boolean#, {default: false}
      t.remove :email4#, :boolean#, {default: false}
    end
  end
end
