class AddImagePathToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :image_path, :string
  end
end
