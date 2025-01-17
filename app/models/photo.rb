require 'exif_reader'
class Photo < ActiveRecord::Base
  acts_as_authorizable
  file_column :image, :jthumb => {}, :exif => {}
  validates_file_format_of :image, :in => ["gif", "png", "jpg"]
  validates_filesize_of :image, :in => 0..50.megabytes
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :album, :counter_cache => true
  validates_presence_of :name,:album_id, :image
  validates_length_of :name, :maximum => 100
  validates_uniqueness_of :name, :case_sensitive => false
  has_one :exif
  def find_comments
    Comment.find(:all, :conditions => ["comment_object_type = 'photo' AND comment_object_id = ?", id])
  end
  
  def score
    view_count*0.2 + comments_count*0.3 + zanns_count*0.5
  end
  
  def view_once
    self.view_count = self.view_count + 1
    self.save
  end

  def zanned_by_user?(user_id)
    zann_count = Zann.count(:conditions => ["zannee_type = 'photo' AND zannee_id = ? AND zanner_id = ?", id, user_id])
    return zann_count>0 ? true : false;
  end 
  
  def before_destroy
    self.accepts_no_role 'creator', self.creator
    Zann.delete_all(["zannee_type = ? AND zannee_id = ?", 'photo', id])
    Comment.delete_all(["comment_object_type = ? AND comment_object_id = ?", 'photo', id])
  end
  
  def self.top_scored
    Photo.find(:all, :order => "view_count*0.2+comments_count*0.3+zanns_count*0.5 DESC", :limit => 10)
  end
  
  def self.photos_count_until_day(date)
    Photo.count(:conditions => ["created_at <= ? ", date.tomorrow])
  end

  def self.find_by_album_and_tag(album_id, tag)
    Photo.find(:all,
      :select => 'photos.*',
      :joins => 'JOIN taggings ON photos.id = taggings.taggable_id JOIN tags ON taggings.tag_id = tags.id',
      :conditions => ['album_id = ? AND tags.name = ?', album_id, tag]
    )
  end

end
