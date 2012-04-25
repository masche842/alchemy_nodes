module AlchemyNodes
  module Admin
    class NodesController < Alchemy::Admin::BaseController

      helper Alchemy::PagesHelper
      helper Alchemy::Admin::PagesHelper
      helper AlchemyNodes::NodesHelper

      #controller.filter_access_to [:show, :unlock, :visit, :publish, :configure, :edit, :update, :destroy, :fold], :attribute_check => true
      #controller.filter_access_to [:index, :link, :layoutpages, :new, :switch_language, :create, :move, :flush], :attribute_check => false

      cache_sweeper Alchemy::PagesSweeper, :only => [:publish], :if => proc { Alchemy::Config.get(:cache_pages) }
      #cache_sweeper Alchemy::ContentablesSweeper, :only => [:publish], :if => proc { Alchemy::Config.get(:cache_pages) }

      def index
        if params[:query].blank?
          items = AlchemyNodes::Node
        else
          search_terms = ActiveRecord::Base.sanitize("%#{params[:query]}%")
          items = AlchemyNodes::Node.where(resource_handler.searchable_attributes.map { |attribute|
            "`#{AlchemyNodes::Node_name.pluralize}`.`#{attribute[:name]}` LIKE #{search_terms}"
          }.join(" OR "))
        end
        instance_variable_set("@#{resource_handler.resources_name}", items.page(params[:page] || 1).per(per_page_value_for_screen_size))
      end

      def show
        load_node
        @container = (@node.containers.find_by_language_id(session[:language_id]) or AlchemyNodes::Container.new(:language_id => session[:language_id]))
        @page = @container
        @preview_mode = true
        # Setting the locale to pages language. so the page content has its correct translation
        ::I18n.locale = Alchemy::Language.get_default.code
        render :layout => layout_for_page
      end

      def new
        @node = AlchemyNodes::Node.new(:parent_id => params[:parent_id])
        @page_layouts = Alchemy::PageLayout.get_layouts_for_select(session[:language_id], false)
        render :layout => false
      end

      # Edit the content of the page and all its elements and contents.
      def edit
        load_node
        @container = (@node.containers.find_by_language_id(session[:language_id]) or @node.containers.create(:language_id => session[:language_id]))
        @page = @container
        @languages = Alchemy::Language.all
        @locked_content_frames = []
        @layoutpage = false
      end

      def create
        parent = Node.find_by_id(params[:node][:parent_id]) or raise "Node.root"
        if params[:paste_from_clipboard].blank?
          node = Node.create(params[:node])
        else
          source_node = Node.find(params[:paste_from_clipboard])
          node = Node.copy(source_node, {
            :name => params[:node][:name].blank? ? source_node.name + ' (' + t('Copy') + ')' : params[:node][:name],
            :urlname => '',
            :title => '',
            :parent_id => params[:node][:parent_id]
          })
          source_node.copy_children_to(node) unless source_node.children.blank?
        end
        render_errors_or_redirect(node, nodeables_path(node), t("Page created", :name => node.name), '#alchemyOverlay button.button')
      end

      def resource_locked_by_other_user
        @node.locked? && @node.locker && @node.locker.logged_in? && @node.locker != current_user
      end

      def update_content
        load_node
        if @node.update_attributes(params[:page])
          @notice = t("Page saved", :name => @node.name)
          @while_page_edit = request.referer.include?('edit')
        else
          render_remote_errors(@node, "form#edit_page_#{@node.id} button.button")
        end
      end

      def link
        @url_prefix = ""
        if configuration(:show_real_root)
          @contentable_root = AlchemyNodes::Node.root
        else
          @contentable_root = AlchemyNodes::Node.language_root_for(session[:language_id])
        end
        @area_name = params[:area_name]
        @content_id = params[:content_id]
        @link_target_options = AlchemyNodes::Node.link_target_options
        @attachments = Attachment.all.collect { |f| [f.name, download_attachment_path(:id => f.id, :name => f.name)] }
        if params[:link_urls_for] == "newsletter"
          # TODO: links in newsletters has to go through statistic controller. there fore we have to put a string inside the content_rtfs and replace this string with recipient.id before sending the newsletter.
          #@url_prefix = "#{current_server}/recipients/reacts"
          @url_prefix = current_server
        end
        if multi_language?
          @url_prefix = "#{session[:language_code]}/"
        end
        render :layout => false
      end

      # Leaves the page editing mode and unlocks the page for other users
      def unlock
        load_node
        @node.current_container.unlock
        flash[:notice] = t("unlocked_page", :name => @node.name)
        @contentables_locked_by_user = AlchemyNodes::Node.all_locked_by(current_user)
        respond_to do |format|
          format.js
          format.html {
            redirect_to params[:redirect_to].blank? ? nodeables_path(@node) : params[:redirect_to]
          }
        end
      end

      def visit
        load_node
        @node.unlock
        redirect_to [alchemy_nodes, @node]
      end

      # Sets the page public and sweeps the page cache
      def publish
        load_node
        @node.public = true
        @node.save
        flash[:notice] = t("page_published", :name => @node.name)
        redirect_back_or_to_default(resources_path)
      end

      def flush
        AlchemyNodes::Node.with_language(session[:language_id]).flushables.each do |page|
          expire_page(page)
        end
        respond_to do |format|
          format.js
        end
      end

      private

      def nodeables_path(node)
        main_app.url_for([:admin, node.root.nodeable.class])
      end

      def current_container

      end

      def pages_from_raw_request
        request.raw_post.split('&').map { |i| i = {i.split('=')[0].gsub(/[^0-9]/, '') => i.split('=')[1]} }
      end

      def expire_page(page)
        return if page.do_not_sweep
        # TODO: We should change this back to expire_action after Rails 3.2 was released.
        # expire_action(
        # 	alchemy.show_page_url(
        # 		:urlname => page.urlname_was,
        # 		:lang => multi_language? ? page.language_code : nil
        # 	)
        # )
        # Temporarily fix for Rails 3 bug
        expire_fragment(
          ActionController::Caching::Actions::ActionCachePath.new(
            self,
            alchemy.show_page_url(:urlname => page.urlname_was, :lang => multi_language? ? page.language_code : nil),
            false
          ).path)
      end

      def load_node
        @node = AlchemyNodes::Node.find(params[:id])
      end

      def switch_language
        set_language_from(params[:language_id])
        redirect_path = request.referer.include?('admin/layoutpages') ? admin_layoutpages_path : admin_pages_path
        if request.xhr?
          @redirect_url = redirect_path
          render :action => :redirect
        else
          redirect_to redirect_path
        end
      end

    end
  end

end