require File.dirname(__FILE__) + '/../test_helper'
require 'tags_controller'

# Re-raise errors caught by the controller.
class TagsController; def rescue_action(e) raise e end; end

class TagsControllerTest < ActionController::TestCase
  def setup
	super
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
