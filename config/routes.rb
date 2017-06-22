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

# Plugin's routes
RedmineApp::Application.routes.draw do
		resources :query_wrapper
		match '/projects/:project_id/issues/create', :controller => 'query_wrapper', :action => 'create', :via => [:post]
		resources :query_wrapper_query
		match '/projects/:project_id/issues/create', :controller => 'query_wrapper_query', :action => 'create', :via => [:post]

end
