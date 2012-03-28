class UpdateStorageOfBalancedProgrammeCache < ActiveRecord::Migration

  def self.up
    ProgrammeReviewBalancedCache.destroy_all
    remove_column :programme_review_balanced_caches, :zone_totals
    remove_column :programme_review_balanced_caches, :method_totals
    add_column :programme_review_balanced_caches, :last_used_at, :timestamp
    add_column :programme_review_balanced_caches, :data, :text
  end

  def self.down
    ProgrammeReviewBalancedCache.destroy_all
    add_column :programme_review_balanced_caches, :zone_totals
    add_column :programme_review_balanced_caches, :method_totals
    remove_column :programme_review_balanced_caches, :last_used_at, :timestamp
    remove_column :programme_review_balanced_caches, :data, :text
  end

end
