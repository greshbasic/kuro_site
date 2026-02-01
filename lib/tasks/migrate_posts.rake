namespace :posts do
  desc "Migrate base64 images from image_data column to Active Storage"
  task migrate_images: :environment do
    posts_with_images = Post.where.not(image_data: [nil, ""])
    total = posts_with_images.count
    puts "Found #{total} posts with base64 images to migrate..."

    posts_with_images.find_each.with_index do |post, index|
      begin
        decoded = Base64.decode64(post.image_data)
        post.image.attach(
          io: StringIO.new(decoded),
          filename: "post_#{post.id}.jpg",
          content_type: "image/jpeg"
        )
        puts "[#{index + 1}/#{total}] Migrated image for post #{post.id}: #{post.title}"
      rescue => e
        puts "[#{index + 1}/#{total}] ERROR migrating post #{post.id}: #{e.message}"
      end
    end

    puts "Done!"
  end

  desc "Import markdown files from app/posts into database"
  task import_markdown: :environment do
    posts_dir = Rails.root.join("app/posts")
    files = Dir.glob(posts_dir.join("*.md"))
    total = files.count
    puts "Found #{total} markdown files to import..."

    files.each.with_index do |file, index|
      basename = File.basename(file, ".md")
      date_str, title_str = basename.split("_", 2)

      # Check if post already exists (by date and title)
      title = title_str ? title_str.tr("_", " ").titleize : "Untitled"
      date = Date.parse(date_str) rescue Date.current

      existing = Post.find_by(post_date: date, title: title)
      if existing
        puts "[#{index + 1}/#{total}] Skipping #{basename} - already exists"
        next
      end

      markdown = File.read(file)

      # Create the post
      post = Post.create!(
        title: title,
        body: markdown,
        post_date: date
      )
      puts "[#{index + 1}/#{total}] Imported: #{basename} -> Post ##{post.id}"
    rescue => e
      puts "[#{index + 1}/#{total}] ERROR importing #{basename}: #{e.message}"
    end

    puts "Done!"
  end

  desc "Regenerate html_content for all posts"
  task regenerate_html: :environment do
    total = Post.count
    puts "Regenerating HTML for #{total} posts..."

    Post.find_each.with_index do |post, index|
      post.save! # Triggers before_save callback
      puts "[#{index + 1}/#{total}] Regenerated HTML for post #{post.id}: #{post.title}"
    end

    puts "Done!"
  end

  desc "Migrate comments from old filenames to db_ID format"
  task migrate_comments: :environment do
    # Build mapping from old filename to new db_ID
    filename_mapping = {}
    Post.find_each do |post|
      # Generate the old filename format: YYYY-MM-DD_title-with-dashes
      date_str = post.post_date.strftime("%Y-%m-%d")
      title_slug = post.title.downcase.tr(" ", "_").gsub(/[^a-z0-9_-]/, "")
      # Try various formats the old filenames might have used
      old_formats = [
        "#{date_str}_#{title_slug}",
        "#{date_str}_#{post.title.downcase.tr(' ', '-')}",
        "#{date_str}_#{post.title.downcase.tr(' ', '_')}"
      ]
      old_formats.each { |f| filename_mapping[f] = "db_#{post.id}" }
    end

    # Find comments with old-style filenames and update them
    comments = Comment.where.not("post_filename LIKE 'db_%'")
    total = comments.count
    puts "Found #{total} comments with old-style filenames..."

    updated = 0
    comments.find_each do |comment|
      new_filename = filename_mapping[comment.post_filename]
      if new_filename
        comment.update!(post_filename: new_filename)
        puts "Updated comment #{comment.id}: #{comment.post_filename} -> #{new_filename}"
        updated += 1
      else
        puts "WARNING: No matching post for comment #{comment.id} with filename: #{comment.post_filename}"
      end
    end

    puts "Done! Updated #{updated} comments."
  end
end
