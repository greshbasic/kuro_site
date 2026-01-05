require_relative "config/environment"

POSTS_DIR = Rails.root.join("app/posts")

latest_post_file = Dir[POSTS_DIR.join("*")].max_by { |f| File.mtime(f) }
latest_post_title = File.basename(latest_post_file)

puts "Sending email for latest post: #{latest_post_title}"

NotifierMailer.new_post(latest_post_title).deliver_now

puts "Email sent!"