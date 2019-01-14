class AddGdprConsentAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :gdpr_consent_at, :timestamp
  end
end
