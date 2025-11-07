# New post controller for admin route
# Manage posts from the admin area

# Inject the post controller
say "#{INDENT}Injecting common header and before_actions into Admin::PostsController...", :blue
unless File.read('app/controllers/admin/posts_controller.rb').include?("before_action :authenticate_admin!")
  inject_into_file 'app/controllers/admin/posts_controller.rb', after: "class Admin::PostsController < ApplicationController" do <<~RUBY

    before_action :authenticate_admin!
    before_action :set_post, only: [ :show, :edit, :update, :destroy, :destroy_image, :meta_destroy_image ]
    before_action :set_post_categories, only: [ :new, :create, :edit, :update ]

    def index
      @featured_blog = Blog.where(featured: true).first
      @blogs = Blog.all.sorted

      if @featured_blog.present?
        @blogs = @blogs.where.not(id: @featured_blog.id)
      end

      respond_to do |format|
        format.html
        format.json { render json: @blogs.as_json(
          only: [ :id, :title, :content, :published_at, :image_url ],
          include: {
            blog_category: { only: [ :title ] },
            milk_admin: { only: [ :email ] }
          }
        )}
      end
    end

    def new
      @post = Post.new
    end

    def create
      @post = current_admin.posts.build(post_params)

      respond_to do |format|
        begin
          if @post.save
            format.html { redirect_to admin_post_path(@post), notice: "Post was successfully created." }
            format.json { render json: @post, status: :created, location: admin_post_path(@post) }
          else
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: @post.errors, status: :unprocessable_entity }
          end
        rescue ActiveRecord::RecordNotUnique => e
          @post.errors.add(:featured, "Only one post can be featured at a time. Please un-feature an existing post first.")
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        begin
          if @post.update(post_params)
            format.html { redirect_to admin_post_path(@post), notice: "Post was successfully updated." }
            format.json { render json: @post, status: :ok }
          else
            format.html { render :edit, status: :unprocessable_entity }
            format.json { render json: @post.errors, status: :unprocessable_entity }
          end
        rescue ActiveRecord::RecordNotUnique => e # Catch unique index violation
          @post.errors.add(:featured, "Only one post can be featured at a time. Please un-feature an existing post first.")
          format.html { render :edit, status: :unprocessable_entity } # Render edit again with errors
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      respond_to do |format|
        if @post.destroy
          format.html { redirect_to admin_posts_path, notice: "Post was successfully destroyed.", status: :see_other }
          format.json { head :no_content }
        else
          format.html { redirect_to admin_posts_path, alert: "Post could not be destroyed." }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy_image
      @post.image.purge_later
      respond_to do |format|
        if @post.image.purge_later # This returns the job, doesn't wait

          # Callback in model will handle this.
          # If needing immediate removal from DB for Turbo frames use:
          # @post.update_columns(image_url: nil)

          format.html { redirect_to edit_admin_post_path(@post), notice: "Image removal scheduled." }
          format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@post, "image")) }
          format.json { render json: { message: "Image removal scheduled." }, status: :ok }
        else
          format.html { redirect_to edit_admin_post_path(@post), alert: "Failed to schedule image removal." }
          format.json { render json: { error: "Failed to schedule image removal." }, status: :unprocessable_entity }
        end
      end
    end

    def meta_destroy_image
      @post.meta_image.purge_later
      respond_to do |format|
        if @post.meta_image.purge_later

          # Callback in model will handle this.
          # If needing immediate removal from DB for Turbo frames use:
          # @post.update_columns(meta_image_url: nil)

          format.html { redirect_to edit_admin_post_path(@post), notice: "Meta image removal scheduled." }
          format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@post, "meta_image")) }
          format.json { render json: { message: "Meta image removal scheduled." }, status: :ok }
        else
          format.html { redirect_to edit_admin_post_path(@post), alert: "Failed to schedule meta image removal." }
          format.json { render json: { error: "Failed to schedule meta image removal." }, status: :unprocessable_entity }
        end
      end
    end

    private

    # Use friendly.find to find by ID or slug
    def set_post
      begin
        @post = Post.friendly.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to admin_posts_path, alert: "Post not found."
      end
    end

    def set_post_categories
      @categories = Category.all.order(:category_name)
    end

    def post_params
      params.require(:post).permit(
        :title,
        :subtitle,
        :published_at,
        :category_id,
        :slug,
        :content,
        :image,
        :meta_image,
        :meta_description,
        :featured,
        keywords: []
      )
    end
RUBY
  end
end
