module AlchemyNodes
  module NodesHelper

    def render_unlock_nodes_bar
      # <div class="subnavi_tab wide" id="locked_page_<%= contentable.id %>">
      #   <%= link_to resource_path(contentable, :action => :edit_content) do %>
      #<span class="page_name" title="<%= contentable.name %>">
      #	<%= truncate contentable.name, :length => 15 %>
      #</span>
      #   <% end %>
      #   <%= form_tag(resource_path(contentable, :action => :unlock), :remote => true) do %>
      #     <button class="icon_button small" title="<%= t('explain_unlocking') %>">
      #       <%= render_icon('close small') %>
      #     </button>
      #   <% end %>
      # </div>
    end

    def nodes_path
      alchemy_nodes.admin_nodes_path
    end

    # Renders the layout from @page.page_layout. File resists in /app/views/page_layouts/_LAYOUT-NAME.html.erb
    def render_node_layout(options={})
      render :partial => "alchemy/page_layouts/#{@node.page_layout.downcase}"
    rescue ActionView::MissingTemplate
      warning("PageLayout: '#{@node.page_layout}' not found. Rendering standard page_layout.")
      render :partial => "alchemy/page_layouts/standard"
    end

  end
end
