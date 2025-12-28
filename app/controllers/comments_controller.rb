class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    c = params.require(:comment).permit(:post_filename, :initials, :body)

    Comment.create!(
      post_filename: c[:post_filename],
      initials: c[:initials].presence || 'N/A',
      body: c[:body],
    )

    redirect_back(fallback_location: root_path)
  end
end
