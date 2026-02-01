class RemoveImageDataFromPosts < ActiveRecord::Migration[8.0]
  def change
    # NOTE: Only run this migration AFTER running the rake task to migrate
    # base64 images to Active Storage:
    #   rails posts:migrate_images
    remove_column :posts, :image_data, :text
  end
end
