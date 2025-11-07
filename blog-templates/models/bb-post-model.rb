# Find the most recently created Post migration file
# Add rich text to Post (assuming Post has a `content` column for ActionText)
# Build out Post model
# Note: Removed redundant `belongs_to` from heredoc, and adjusted `after:` target.
inject_into_file "app/models/post.rb", after: "belongs_to :admin\n" do <<~RUBY
  has_many :post_categories, dependent: :destroy
  has_many :categories, through: :post_categories
  has_rich_text :content

  validates :title, :admin_id, :content, presence: true

  has_one_attached :image, dependent: :destroy
  has_one_attached :meta_image, dependent: :destroy

  # after_commit :set_direct_image_urls

  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  # set up scopes for sorted, scheduled, published, and draft
  scope :sorted, -> { order(arel_table[:published_at].desc.nulls_last).order(updated_at: :desc) }
  scope :draft, -> { where(published_at: nil) }
  scope :published, -> { where("published_at <= ?", Time.current) }
  scope :scheduled, -> { where("published_at > ?", Time.current) }

  private

  # Is the blog post a draft?
  #
  # A blog post is a draft if it doesn't have a published_at date.
  def draft?; published_at.nil?; end
  # Is the blog post published?
  #
  # A blog post is published if it has a published_at date and
  # that date is in the past.
  def published?; published_at? && published_at <= Time.current; end
  # Is the blog post scheduled?
  #
  # A blog post is scheduled if it has a published_at date and
  # that date is in the future.
  def scheduled?; published_at? && published_at > Time.current; end
RUBY
end
