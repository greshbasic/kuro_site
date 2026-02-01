class ImportMarkdownPostsAndMigrateComments < ActiveRecord::Migration[8.0]
  def up
    # Add backup column for original filename (for safe rollback)
    unless column_exists?(:comments, :original_filename)
      add_column :comments, :original_filename, :string
    end

    # Step 1: Import markdown files to database
    posts_dir = Rails.root.join("app/posts")
    files = Dir.glob(posts_dir.join("*.md"))

    filename_to_post_id = {}

    files.each do |file|
      basename = File.basename(file, ".md")
      date_str, title_str = basename.split("_", 2)

      title = title_str ? title_str.tr("_", " ").titleize : "Untitled"
      date = Date.parse(date_str) rescue Date.current

      # Skip if already exists
      existing = Post.find_by(post_date: date, title: title)
      if existing
        filename_to_post_id[basename] = existing.id
        next
      end

      markdown = File.read(file)
      post = Post.create!(
        title: title,
        body: markdown,
        post_date: date
      )
      filename_to_post_id[basename] = post.id
      say "Imported: #{basename} -> Post ##{post.id}"
    end

    # Step 2: Migrate comments from old filenames to db_ID format
    filename_mapping = {}
    filename_to_post_id.each do |old_filename, post_id|
      filename_mapping[old_filename] = "db_#{post_id}"
    end

    # Update comments - save original before changing
    comments_updated = 0
    Comment.where.not("post_filename LIKE 'db_%'").find_each do |comment|
      new_filename = filename_mapping[comment.post_filename]
      if new_filename
        comment.update!(
          original_filename: comment.post_filename,
          post_filename: new_filename
        )
        comments_updated += 1
      end
    end
    say "Updated #{comments_updated} comments to new filename format"
  end

  def down
    # Restore original filenames from backup
    if column_exists?(:comments, :original_filename)
      Comment.where.not(original_filename: nil).find_each do |comment|
        comment.update!(post_filename: comment.original_filename)
      end
      remove_column :comments, :original_filename
    end
  end
end
