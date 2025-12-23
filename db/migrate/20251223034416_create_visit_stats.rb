class CreateVisitStats < ActiveRecord::Migration[8.0]
  def change
    create_table :visit_stats do |t|
      t.date :date
      t.integer :count

      t.timestamps
    end
  end
end
