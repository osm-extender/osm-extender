class AddGdprConsentAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gdpr_consent_at, :timestamp
  end
end
