#Copyright (C) 2017  Alexandre BOUDINE
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

module IssuesHelperPatch
	def self.included(base)
		base.class_eval do

			def charge_wrappers #Select every public wrappers, or privates wrapper of the current User
				@wrappers = QueryWrapper.all.order("#{QueryWrapper.table_name}.title ASC").where(@project.nil? ? ["project_id IS NULL"] : ["project_id IS NULL OR project_id = ?", @project.id]).to_a
				@res = @wrappers.select{|tmp| (tmp[:user_id] == User.current.id) }
				@res += @wrappers.select{|tmp| (tmp[:visibility] == true)}
				@res = @res.uniq
				return @res
			end

			def queries_for_wrapper(queries, wrapper = nil) #Select every queries linked to a directory
				if wrapper != nil then #If there is a directory, select all linked queries to this directory
					@res = queries.select{|tmp| (QueryWrapperQuery.find_by_query_id(tmp[:id]) != nil)}
					@res = @res.select{|tmp| (QueryWrapperQuery.find_by_query_id(tmp[:id]).query_wrapper_id == wrapper.id)}
				else #else, select all unlinked queries
					@res = queries.select{|tmp| (QueryWrapperQuery.find_by_query_id(tmp[:id]) == nil)}
				end
				if @res.nil? then
			    	@res = []
			    end
				return @res
			end


			def query_links_with_plugin(title, queries, visibility) #Override with more content
			    return '' if queries.empty?
			    # links to #index on issues/show
			    url_params = controller_name == 'issues' ? {:controller => 'issues', :action => 'index', :project_id => @project} : params

			    @wrappers = charge_wrappers
			    @wrappers = @wrappers.select{|tmp| (tmp[:visibility] == visibility)}

			    if @wrappers.nil? then
			    	@wrappers = []
			    end

			    content_tag('h3', title) + "\n" +

			      content_tag('ul',
			      		@wrappers.collect {|w|
			      			content_tag('li',
			      				link_to(w.title, 'javascript:;', :onclick => "$('.content_wrap_id_'+"+w.id.to_s+").toggle();($(this).hasClass('collapsed') ? $(this).removeClass('collapsed') : $(this).addClass('collapsed'));", :class => 'collapsible collapsed wrap wrap_id_'+w.id.to_s,)+
			      				link_to_if(User.current.allowed_to?(:manage_public_query_wrappers, nil, :global => true) || !visibility,'',query_wrapper_path(w.id),data: {:confirm => l(:confirmation)}, :method => :delete, :class => 'icon icon-del') +
			      				link_to_if(User.current.allowed_to?(:manage_public_query_wrappers, nil, :global => true) || !visibility,'', "javascript:;", :class => 'icon icon-edit', :onclick => "$('.show_wrap_'+"+w.id.to_s+").toggle();$('.edit_wrap_'+"+w.id.to_s+").toggle();"),
			      			:class => 'show_wrap_'+w.id.to_s)+
			      			content_tag('li',
			      				render(:partial => 'queries_views/edit_form_query_wrapper', :locals => {:object => w})+			
								link_to(l(:cancel_button), "javascript:;", :onclick => "$('.show_wrap_'+"+w.id.to_s+").toggle();$('.edit_wrap_'+"+w.id.to_s+").toggle();"),
			      			:class => 'edit_wrap_'+w.id.to_s, :style => "display:none;")+
			      			content_tag('ul',
			      				queries_for_wrapper(queries,w).collect{|q|
			      					css = 'query'
			           				css << ' selected' if q == @query
			      					content_tag('li', link_to(q.name, url_params.merge(:query_id => q), :class => css))	      					
			      				}.join("\n").html_safe,
			      			:class => 'queries content_wrap_id_'+w.id.to_s, :style => "display:none;margin-left:25px;")
			    		}.join("\n").html_safe

			      	) + "\n" +

			      content_tag('ul',
			        queries_for_wrapper(queries,nil).collect {|query|
			            css = 'query'
			            css << ' selected' if query == @query
			            content_tag('li', link_to(query.name, url_params.merge(:query_id => query), :class => css))
			          }.join("\n").html_safe,
			        :class => 'queries'
			      ) + "\n" +

			      (User.current.allowed_to?(:manage_public_query_wrappers, nil, :global => true) || !visibility ?

			      content_tag('hr','', :style => "margin-top:15px;margin-bottom:15px;")+"\n"+
			      link_to(l(:add_wrapper_link), {}, :onclick => "$('.a_wrap_"+visibility.to_s+"').toggle();$('.div_wrap_"+visibility.to_s+"').toggle();return false;", :class => 'a_wrap_'+visibility.to_s) + "\n" +
			      content_tag('div', '',:class => ('div_wrap_'+visibility.to_s), :style => "display: none")
			      : '')
			end

			def render_sidebar_queries_with_plugin #Override with a boolean parameter
			    out = ''.html_safe
			    out << query_links(l(:label_my_queries), sidebar_queries.select(&:is_private?), false)
			    out << query_links(l(:label_query_plural), sidebar_queries.reject(&:is_private?), true)
			    out
			end

			alias_method_chain :query_links, :plugin
			alias_method_chain :render_sidebar_queries, :plugin
		end
	end
end