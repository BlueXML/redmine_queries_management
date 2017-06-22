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

require 'redmine'
require_dependency 'queries_hooks/hook' #Apply views modifications

Rails.configuration.to_prepare do
	require_dependency 'issues_helper_patch' #Applu patch
	IssuesHelper.send(:include, IssuesHelperPatch)
end

Redmine::Plugin.register :redmine_queries_management do
  name 'Queries Management plugin'
  author 'Alexandre BOUDINE'
  description 'Help sorting queries'
  version '0.1.0'
  url ''
  author_url ''

  project_module :issue_tracking do
  	permission :manage_public_query_wrappers, :query_wrapper => [:create, :edit, :destroy, :update]
  end
end
