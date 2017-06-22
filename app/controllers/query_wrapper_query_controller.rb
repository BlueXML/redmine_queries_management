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

class QueryWrapperQueryController < ApplicationController
  unloadable

  #Check permissions before create
  before_filter :validate_create, :only => [:create]

  def index
  end

  def create
    @qwq = QueryWrapperQuery.find_by_query_id(params[:query_id])
    if @qwq != nil #If a link with the query already exist
      if params[:wrapper_id] == '-1' then #But we want to unlink, then destroy it
        @qwq.destroy
      else
        @qwq.query_wrapper_id = params[:wrapper_id] #Or we link it to another directory
        @qwq.save
      end
    else #else, we create a new link between the query and the directory
      @qwq = QueryWrapperQuery.new
      @qwq.query_wrapper_id = params[:wrapper_id]
      @qwq.query_id = params[:query_id]
      @qwq.save
    end

    respond_to do |format|
      format.html { redirect_to_issues(:set_filter => params[:query_id]) }
      format.xml { head :ok }
    end
  end

  private

  def redirect_to_issues(options) #Redirect
    @wrap = QueryWrapper.find(params[:wrapper_id]) if params[:wrapper_id] != '-1'
    @project = Project.find(@wrap.project_id) if @wrap != nil && @wrap.project_id != nil
    if params[:gantt]
      if @project
        redirect_to project_gantt_path(@project, options)
      else
        redirect_to issues_gantt_path(options)
      end
    else
      if @project
        redirect_to _project_issues_path(@project, options)
      else
        redirect_to issues_path(options)
      end
    end
  end

  #Check permissions
  def validate_create
    @tmp = params[:wrapper_id]
    if @tmp != '-1' then
      @wrapper = QueryWrapper.find(params[:wrapper_id])
      if @wrapper.visibility? then
        render_403 unless User.current.allowed_to?(:manage_public_query_wrappers, @project, :global => true) or User.current.admin?
      end
    else
      @query = Query.find(params[:query_id])
      if @query.visibility >= 1 then
        render_403 unless User.current.allowed_to?(:manage_public_query_wrappers, @project, :global => true) or User.current.admin?
      end
    end
  end
end
