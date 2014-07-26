require 'test_helper'

class TagsControllerTest < ActionController::TestCase

	test "'index' action returns a list of all tags" do
		get :index
		body = JSON.parse(response.body)
		assert_equal Tag.count, body['tags'].length
	end

	test "updates the 'name' attribute via the 'update' method" do
		tag = Tag.create!(name: 'test')

		put :update, id: tag.id, tag: { name: 'new name' }
		assert_equal 'new name', assigns(:tag).name
	end

	test "'update' action responds with JSON" do
		tag = Tag.create!(name: 'test')
		put :update, id: tag.id, tag: { name: 'new name' }

		assert_response :success
		body = JSON.parse(response.body)
		assert_equal 'new name', body['tag']['name']
	end

end