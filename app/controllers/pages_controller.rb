class PagesController < ApplicationController
  POSTS_PER_PAGE = 5

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
    @page = (params[:page] || 1).to_i

    # Build query with date filtering
    posts_query = Post.order(post_date: :desc)

    if params[:year].present?
      year = params[:year].to_i
      if params[:month].present?
        month = params[:month].to_i
        if params[:day].present?
          day = params[:day].to_i
          date = Date.new(year, month, day)
          posts_query = posts_query.where(post_date: date)
        else
          start_date = Date.new(year, month, 1)
          end_date = start_date.end_of_month
          posts_query = posts_query.where(post_date: start_date..end_date)
        end
      else
        start_date = Date.new(year, 1, 1)
        end_date = Date.new(year, 12, 31)
        posts_query = posts_query.where(post_date: start_date..end_date)
      end
    end

    # Get total count for pagination
    total_posts = posts_query.count
    @total_pages = (total_posts / POSTS_PER_PAGE.to_f).ceil

    # Fetch only the posts for this page (proper DB pagination)
    # Use with_attached_image to eager load attachments in a single query
    @db_posts = posts_query
      .with_attached_image
      .offset((@page - 1) * POSTS_PER_PAGE)
      .limit(POSTS_PER_PAGE)

    # Build posts array with cached HTML and Active Storage image URLs
    comment_counts = Comment.group(:post_filename).count
    @posts = @db_posts.map do |post|
      post_hash = {
        filename: "db_#{post.id}",
        title: post.title,
        date: post.post_date.strftime('%Y-%m-%d'),
        content: post.html_content,
        db_post: true,
        post_id: post.id,
        comment_count: comment_counts["db_#{post.id}"] || 0
      }
      # Include image URL if the post has an attached image
      if post.image.attached?
        post_hash[:image_url] = Rails.application.routes.url_helpers.rails_blob_path(post.image, only_path: true)
      end
      post_hash
    end
  end

  def create_post
    if params[:password] != ENV['POST_PASSWORD']
      flash[:error] = "Wrong password!"
      redirect_to blog_path and return
    end

    post = Post.create!(
      title: params[:title],
      body: params[:body],
      post_date: params[:post_date].present? ? Date.parse(params[:post_date]) : Date.current
    )

    # Attach image using Active Storage instead of base64
    if params[:image].present?
      post.image.attach(params[:image])
    end

    NotifierMailer.new_db_post(post).deliver_now

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

    # All posts are now in database (after import)
    post_id = filename.sub('db_', '').to_i
    @post_record = Post.find(post_id)

    @post = {
      title: @post_record.title,
      filename: filename,
      date: @post_record.post_date.strftime('%Y-%m-%d'),
      content: @post_record.html_content
    }

    @comments =
      Comment.where(post_filename: @post[:filename]).order(created_at: :desc)
    @comment = Comment.new(post_filename: params[:filename])
  end
end
