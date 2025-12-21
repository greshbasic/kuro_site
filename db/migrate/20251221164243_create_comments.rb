class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.string :post_filename
      t.string :author
      t.text :body

      t.timestamps
    end
  end
end
