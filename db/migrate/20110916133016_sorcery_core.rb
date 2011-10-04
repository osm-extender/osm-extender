class SorceryCore < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email_address,    :null => false
      t.string :crypted_password, :default => nil
      t.string :salt,             :default => nil

      t.timestamps
    end

    add_index :users, :email_address, :unique => true
  end

  def self.down
    drop_table :users
  end
end