class AddOsmApiToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :osm_userid, :text, :limit=>6
    add_column :users, :osm_secret, :text, :limit=>32
  end
end
