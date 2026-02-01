class RemoveImageDataFromPosts < ActiveRecord::Migration[8.0]
  def up
    # Migrate base64 images to Active Storage before removing the column
    Post.where.not(image_data: [nil, ""]).find_each do |post|
      decoded = Base64.decode64(post.image_data)
      post.image.attach(
        io: StringIO.new(decoded),
        filename: "post_#{post.id}.jpg",
        content_type: "image/jpeg"
      )
      say "Migrated image for post #{post.id}: #{post.title}"
    rescue => e
      say "ERROR migrating post #{post.id}: #{e.message}"
    end

    remove_column :posts, :image_data, :text
  end

  def down
    add_column :posts, :image_data, :text
  end
end
