require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "caches html_content on create" do
    post = Post.create!(
      title: "Test Post",
      body: "**bold** and _italic_",
      post_date: Date.current
    )

    assert post.html_content.present?, "html_content should be populated"
    assert_includes post.html_content, "<strong>bold</strong>"
    assert_includes post.html_content, "<em>italic</em>"
  end

  test "updates html_content on save" do
    post = Post.create!(
      title: "Test Post",
      body: "original content",
      post_date: Date.current
    )

    original_html = post.html_content
    post.update!(body: "**updated content**")

    assert_not_equal original_html, post.html_content
    assert_includes post.html_content, "<strong>updated content</strong>"
  end

  test "can attach image via Active Storage" do
    post = Post.create!(
      title: "Test Post",
      body: "test",
      post_date: Date.current
    )

    assert_not post.image.attached?

    post.image.attach(
      io: StringIO.new("fake image data"),
      filename: "test.jpg",
      content_type: "image/jpeg"
    )

    assert post.image.attached?
  end

  test "validates presence of required fields" do
    post = Post.new

    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
    assert_includes post.errors[:body], "can't be blank"
    assert_includes post.errors[:post_date], "can't be blank"
  end
end
