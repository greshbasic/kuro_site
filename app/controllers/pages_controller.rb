class PagesController < ApplicationController
  POSTS_PER_PAGE = 5
  POST_PASSWORD = "Kuro422"

  def home
    today = Date.current
    stat = VisitStat.find_or_initialize_by(date: today)
    stat.count ||= 0
    stat.count += 1
    stat.save!
  end

  def kuro_pictures
    @images =
      Dir
        .glob(Rails.root.join('app/assets/images/kuro/*.{jpg,jpeg,png,gif}'))
        .map { |f| "kuro/#{File.basename(f)}" }

    @img_captions = {
      'kuro/adopt.jpg' => 'day i adopted owner',
      'kuro/baby.jpg' => 'first baf',
      'kuro/chair.jpg' => 'favorite chare',
      'kuro/chillin.jpg' => 'chillin.',
      'kuro/eepy.jpg' => 'so eepy',
      'kuro/hiding.jpg' => 'can u find me?',
      'kuro/strut.jpg' => 'woooo',
      'kuro/window_nap.jpg' => 'window time',
      'kuro/working.jpg' => 'me making page',
      'kuro/yoga.jpg' => 'what u look at',
    }
  end

  def kuro_toys
    @toys =
      Dir
        .glob(Rails.root.join('app/assets/images/toys/*.{jpg,jpeg,png,gif}'))
        .map { |f| "toys/#{File.basename(f)}" }

    @toy_captions = {
      'toys/mouse_wand.jpg' => 'i like to play this in baftub',
      'toys/octopus.jpg' => 'michael',
      'toys/puzzle1.jpg' => 'i like 2 take the balls out',
      'toys/puzzle2.jpg' => 'spin spin',
      'toys/spring.jpg' => 'why do they keep leaving me',
      'toys/table_toy.jpg' => 'i want to take it off',
    }
  end

  def memoriam
    @pets =
      Dir
        .glob(
          Rails.root.join('app/assets/images/memoriam/*.{jpg,jpeg,png,gif}'),
        )
        .map { |f| "memoriam/#{File.basename(f)}" }

    @pet_captions = {
      'memoriam/zoe.jpg' => 'Zoe Bubbles',
      'memoriam/zeke.jpg' => 'Zeke Giggles',
      'memoriam/ed_mu.jpg' => 'Edgar and Mushi',
    }
  end

  def blog
    # Load posts from markdown files
    file_posts =
      Dir
        .glob(Rails.root.join('app/posts/*.md'))
        .map do |file|
          basename = File.basename(file, '.md')
          date_str, title_str = basename.split('_', 2)

          markdown = File.read(file)
          markdown =
            markdown.gsub(/!\[([^\]]*)\]\(([^)]+)\)/) do |match|
              alt = $1
              path = $2
              "![#{alt}](#{ActionController::Base.helpers.asset_path(path)})"
            end

          {
            filename: basename,
            title: title_str ? title_str.tr('_', ' ').titleize : 'Untitled',
            date: date_str,
            content: Kramdown::Document.new(markdown).to_html,
          }
        end

    # Load posts from database
    db_posts = Post.all.map do |post|
      content = Kramdown::Document.new(post.body).to_html
      if post.image_data.present?
        img_tag = "<img src=\"data:image/jpeg;base64,#{post.image_data}\" style=\"max-width:100%; height:auto;\" />"
        content += img_tag
      end
      {
        filename: "db_#{post.id}",
        title: post.title,
        date: post.post_date.strftime('%Y-%m-%d'),
        content: content,
        db_post: true
      }
    end

    all_posts = file_posts + db_posts

    if params[:year].present?
      year = params[:year].to_s.strip
      month = params[:month].to_s.strip.rjust(2, '0') if params[:month].present?
      day = params[:day].to_s.strip.rjust(2, '0') if params[:day].present?

      prefix = year
      prefix += "-#{month}" if month.present?
      prefix += "-#{day}" if day.present?

      all_posts = all_posts.select { |p| p[:date].start_with?(prefix) }
    end

    @posts = all_posts.sort_by { |p| p[:date] }.reverse
    @page = (params[:page] || 1).to_i
    @total_pages = (@posts.size / POSTS_PER_PAGE.to_f).ceil
    @posts = @posts.slice((@page - 1) * POSTS_PER_PAGE, POSTS_PER_PAGE)

    comment_counts = Comment.group(:post_filename).count
    @posts =
      @posts.map do |post|
        post.merge(comment_count: comment_counts[post[:filename]] || 0)
      end
  end

  def create_post
    if params[:password] != POST_PASSWORD
      flash[:error] = "Wrong password!"
      redirect_to blog_path and return
    end

    image_data = nil
    if params[:image].present?
      image_data = Base64.strict_encode64(params[:image].read)
    end

    post = Post.create!(
      title: params[:title],
      body: params[:body],
      post_date: Date.current,
      image_data: image_data
    )

    NotifierMailer.new_db_post(post).deliver_later

    flash[:success] = "Post created!"
    redirect_to blog_path
  end

  def places
    @places =
      Dir
        .glob(Rails.root.join('app/assets/images/places/*.{jpg,jpeg,png,gif}'))
        .map { |f| "places/#{File.basename(f)}" }
  end

  def show_post
    filename = params[:filename]

    if filename.start_with?('db_')
      # Database post
      post_id = filename.sub('db_', '').to_i
      post = Post.find(post_id)
      content = Kramdown::Document.new(post.body).to_html
      if post.image_data.present?
        img_tag = "<img src=\"data:image/jpeg;base64,#{post.image_data}\" style=\"max-width:100%; height:auto;\" />"
        content += img_tag
      end
      @post = {
        title: post.title,
        filename: filename,
        date: post.post_date.strftime('%Y-%m-%d'),
        content: content
      }
    else
      # File-based post
      file = Rails.root.join("app/posts/#{filename}.md")
      markdown = File.read(file)

      markdown.gsub!(/!\[([^\]]*)\]\(([^)]+)\)/) do |match|
        alt = $1
        path = $2
        "![#{alt}](#{ActionController::Base.helpers.asset_path(path)})"
      end

      @post = {
        title: filename.split('_', 2)[1].tr('_', ' ').titleize,
        filename: filename,
        date: filename.split('_', 2)[0],
        content: Kramdown::Document.new(markdown).to_html,
      }
    end

    @comments =
      Comment.where(post_filename: @post[:filename]).order(created_at: :desc)
    @comment = Comment.new(post_filename: params[:filename])
  end
end
