require File.dirname(__FILE__) + '/../test_helper'
require 'thumbnail'
class PhotoTest < ActiveSupport::TestCase
  include ImageProcessing
  fixtures :photos, :zanns, :comments, :users
  
  def setup
    setup_fixture_files
  end
  
  def test_zanns_count
    photo_shanghai = photos(:shanghai_1)
    assert_equal 2, photo_shanghai.zanns_count
    assert_equal 0, photos(:cat_9).zanns_count
  end
  
  def test_view_once
    photo_shanghai = photos(:shanghai_1)
    assert_equal 20, photo_shanghai.view_count
    photo_shanghai.view_once
    assert_equal 21, photo_shanghai.view_count
  end
  
  def test_destroy
    commented_photo = photos(:shanghai_2)
    assert_equal 2, Comment.find(:all).length
    commented_photo.destroy
    assert_equal 0, Comment.find(:all).length
    zanned_photo = photos(:shanghai_1)
    assert_equal 2, Zann.find(:all).length
    zanned_photo.destroy
    assert_equal 0, Zann.find(:all).length
  end
  
  def test_photos_count_in_one_day 
    photos_count = Photo.photos_count_until_day(Time.now)
    assert_equal 17, photos_count
    photos_count = Photo.photos_count_until_day(2.days.ago(Time.now))
    assert_equal 14, photos_count
  end
  
  def test_top_scored_photos
    top_scored_photos = Photo.top_scored
    assert top_scored_photos.length == 10
    assert top_scored_photos[0].score >= top_scored_photos[1].score
    assert top_scored_photos[1].score >= top_scored_photos[2].score
  end

  def test_create_photo_thumb
    photo = Photo.new(
      :name => 'thumbnail test',
      :album_id => 1,
      :image => upload(File.join(RAILS_ROOT, 'test', 'unit', 'data', 'apple.jpg'))
    )
    assert photo.save
    assert File.exist?(medium_size_image_name(photo.image))
    assert File.exist?(small_size_image_name(photo.image))
  end
  
  def test_extract_photo_exif
    photo = Photo.new(
      :name => 'exif test',
      :album_id => 1,
      :image => upload(File.join(RAILS_ROOT, 'test', 'unit', 'data', 'test.jpg'))
    )
    assert photo.save
    assert_not_nil photo.exif
    assert_equal "'NIKON D50'", photo.exif.model
    assert_equal "10/80", photo.exif.exposure_time
  end

  def test_find_photo_by_album_and_tag
     shanghai_photos = Photo.find_by_album_and_tag(1, 'shanghai') 
     assert 2, shanghai_photos.length
     subway_photos = Photo.find_by_album_and_tag(1, 'subway') 
     assert 1, subway_photos.length
  end

  def teardown
    teardown_fixture_files
  end
end
