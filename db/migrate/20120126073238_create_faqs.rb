class CreateFaqs < ActiveRecord::Migration[4.2]
  def change
    create_table :faqs do |t|
      t.string :question
      t.text :answer
      t.boolean :active, :default => true

      t.timestamps
    end
  end
end
