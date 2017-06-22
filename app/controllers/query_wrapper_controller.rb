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

class QueryWrapperController < ApplicationController
  unloadable

  #Check permissions before create, or any methods
  before_filter :validate_create, :only => [:create]
  before_filter :validate, :only => [:destroy, :edit, :update]

  def index
  end

  def create
    if params[:title].blank? then #If title incorrect, flash error
      redirect_to_issues(:set_filter => 1)
      flash[:error] = l(:error_name_flag)
    else #else create the wrapper with the params and redirect
      @wrapper = QueryWrapper.new
      @wrapper.visibility = params[:visibility]
      @wrapper.title = params[:title]
      @wrapper.user_id = User.current.id
      if params[:project_id] then
        @wrapper.project_id = params[:project_id]
      end
      @wrapper.save
      redirect_to_issues(:set_filter => 1)
    end
  end

  def destroy #destroy the wrapper
    @wrapper = QueryWrapper.find(params[:id])
    @project = Project.find(@wrapper.project_id) if @wrapper.project_id != nil #Store the project ID for redirect
    @wrapper.destroy

    @qwq = QueryWrapperQuery.all.where(["query_wrapper_id = ?", params[:id]]).to_a #destroy also all links with related queries
    @qwq.each do |q|
      q.destroy
    end

    respond_to do |format|
      format.html { redirect_to_issues(:set_filter => 1) }
      format.xml { head :ok }
    end
  end

  def edit #Method unused, to be deleted ?
    @wrapper = QueryWrapper.find(params[:id])
    @wrapper.title = params[:title]
    @wrapper.save
    redirect_to_issues(:set_filter => 1)
  end

  def update #Change title if valid
    if params[:title].blank? then
      @project = Project.find(@wrapper.project_id) if @wrapper.project_id != nil
      redirect_to_issues(:set_filter => 1)
      flash[:error] = l(:error_name_flag)
    else
      @wrapper = QueryWrapper.find(params[:id])
      @wrapper.title = params[:title]
      @project = Project.find(@wrapper.project_id) if @wrapper.project_id != nil
      @wrapper.save
      redirect_to_issues(:set_filter => 1)
    end
  end

  private

  def redirect_to_issues(options) #Redirect
    @project = Project.find(params[:project_id]) if params[:project_id]
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
  def validate
    @wrapper = QueryWrapper.find(params[:id])
    if @wrapper.visibility? then
      render_403 unless User.current.allowed_to?(:manage_public_query_wrappers, @project, :global => true) or User.current.admin?
    end
  end

  def validate_create
    @wrapper = QueryWrapper.new
    @wrapper.visibility = params[:visibility]
    if @wrapper.visibility? then
      render_403 unless User.current.allowed_to?(:manage_public_query_wrappers, @project, :global => true) or User.current.admin?
    end
  end
end
