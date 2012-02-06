class CreateProgrammeReviewBalancedCaches < ActiveRecord::Migration
  def change
    create_table :programme_review_balanced_caches do |t|
      t.integer :term_id, :null => false
      t.integer :section_id, :null => false
      t.text :zone_totals
      t.text :method_totals

      t.timestamps
    end
  end
end
