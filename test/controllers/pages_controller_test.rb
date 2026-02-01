require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_path
    assert_response :success
  end

  test "should get pictures" do
    get kuro_pictures_path
    assert_response :success
  end

  test "blog renders successfully" do
    # Create a few posts
    3.times do |i|
      Post.create!(
        title: "Test Post #{i}",
        body: "Content #{i}",
        post_date: Date.current - i.days
      )
    end

    get blog_path
    assert_response :success
    assert_select "h2", text: "Test Post 0"
  end

  test "blog pagination works with many posts" do
    # Create 7 posts (more than 5 per page)
    7.times do |i|
      Post.create!(
        title: "Pagination Post #{i}",
        body: "Content #{i}",
        post_date: Date.current - i.days
      )
    end

    # First page should have 5 posts
    get blog_path
    assert_response :success
    assert_select "h2", count: 5

    # Second page should have 2 posts
    get blog_path(page: 2)
    assert_response :success
    assert_select "h2", count: 2
  end

  test "blog renders cached html with markdown formatting" do
    Post.create!(
      title: "Markdown Test",
      body: "**bold text** and _italic_",
      post_date: Date.current
    )

    get blog_path
    assert_response :success
    assert_match "<strong>bold text</strong>", response.body
    assert_match "<em>italic</em>", response.body
  end

  test "blog filters by year" do
    Post.create!(title: "Old Post", body: "test", post_date: Date.new(2025, 6, 15))
    Post.create!(title: "New Post", body: "test", post_date: Date.new(2026, 1, 15))

    get blog_path(year: 2025)
    assert_response :success
    assert_match "Old Post", response.body
    assert_no_match(/New Post/, response.body)
  end

  test "show_post renders cached html" do
    post = Post.create!(
      title: "Show Test",
      body: "_italic text_",
      post_date: Date.current
    )

    get blog_show_path(filename: "db_#{post.id}")
    assert_response :success
    assert_match "<em>italic text</em>", response.body
  end
end
