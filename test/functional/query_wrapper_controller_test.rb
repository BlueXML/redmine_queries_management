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

require File.expand_path('../../test_helper',__FILE__)

class QueryWrapperControllerTest < ActionController::TestCase

	fixtures :projects, :users, :roles, :members, :member_roles, :issues, :queries, :query_wrappers, :query_wrapper_queries

	setup do
            @controller = QueryWrapperController.new

            @project = Project.find(1)  
            @project.enable_module! :issue_tracking
            @role = Role.find(1)
            User.current = nil
            @request.session[:user_id] = 3
            @query1 = Queries.find(2) #Private query for project 1
            @query2 = Queries.find(3) #Private query global
            @query3 = Queries.find(4) #Public query global
            @query4 = Queries.find(7) #Public query for project 2
	end
	
      test 'create without permission' do
            #user not allowed to manage wrappers
            #create private global wrapper
            @query_wrapper = QueryWrapper.create! title: "WrapPrivate1", visibility: false, user_id: User.current.id

            assert_response :redirect

            #create private project wrapper
            @query_wrapper = QueryWrapper.create! title: "WrapPrivate2", visibility: false, project_id: @project.id, user_id: User.current.id

            assert_response :redirect

            #create public global wrapper
            @query_wrapper = QueryWrapper.create! title: "WrapPublic1", visibility: true, user_id: User.current.id

            assert_response 403

            #create public project wrapper
            @query_wrapper = QueryWrapper.create! title: "WrapPublic2", visibility: true, project_id: @project.id, user_id: User.current.id

            assert_response 403

      end

      test 'create with permission' do
            #user allowed to manage wrappers
            #create private global wrapper

            #create private project wrapper

            #create public global wrapper

            #create public project wrapper

      end

      test 'destroy without permission' do
            #user not allowed to manage wrappers
            #destroy private wrapper

            #destroy public wrapper

      end

      test 'destroy with permission' do
            #user allowed to manage wrappers
            #destroy private wrapper

            #destroy public wrapper

      end

      test 'update without permission' do
            #user not allowed to manage wrappers
            #update private wrapper

            #update public wrapper

      end

      test 'update with permission' do
            #user allowed to manage wrappers
            #update private wrapper

            #update public wrapper

      end
end