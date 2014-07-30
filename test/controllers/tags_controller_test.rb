require 'test_helper'

class TagsControllerTest < ActionController::TestCase

	test "'index' action returns a list of all tags" do
		get :index
		body = JSON.parse(response.body)
		assert_equal Tag.count, body['tags'].length
	end

	test "updates the 'name' attribute via the 'update' method" do
		put :update, id: tags(:one), tag: { name: 'new name' }
		assert_equal 'new name', assigns(:tag).name
	end

	test "'update' action responds with JSON" do
		put :update, id: tags(:one), tag: { name: 'new name' }

		assert_response :success
		body = JSON.parse(response.body)
		assert_equal 'new name', body['tag']['name']
	end

	test "can create a new tag" do
		assert_difference 'Tag.count' do
			post :create, tag: { name: 'a new tag' }
		end
	end

	test "creating a new tag responds with HTTP status 201 (created)" do
		post :create, tag: { name: 'a new tag' }
		assert_response :created
	end

	test "creating a new tag responds with JSON for the new tag" do
		post :create, tag: { name: 'a new tag' }
		body = JSON.parse(response.body)
		assert_equal 'a new tag', body['tag']['name']
	end

end