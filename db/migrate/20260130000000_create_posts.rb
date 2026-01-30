class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.date :post_date, null: false
      t.text :image_data

      t.timestamps
    end
  end
end
