class PagesController < ApplicationController
  POSTS_PER_PAGE = 5

  def home; end

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

  def blog
    all_posts =
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
  end

  def places
    @places =
      Dir
        .glob(Rails.root.join('app/assets/images/places/*.{jpg,jpeg,png,gif}'))
        .map { |f| "places/#{File.basename(f)}" }
  end
end
