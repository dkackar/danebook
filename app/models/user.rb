class User < ActiveRecord::Base

  has_one  :profile,  dependent:   :destroy
  has_many :posts,    dependent:   :destroy
  has_many :comments, dependent:   :destroy
  has_many :likes,    dependent:   :destroy
  
  before_create :generate_token
  has_secure_password

  validates_presence_of :username,  uniqueness: true
  validates_presence_of :email,     uniqueness: true
  validates_format_of   :email,     without: /NOSPAM/
  validates :password,
            :length => {:in => 8..20},
            :allow_nil => true


  accepts_nested_attributes_for :profile,
                               :reject_if => :all_blank,
                               :allow_destroy => true
  def generate_token
    begin
      self[:auth_token] = SecureRandom.urlsafe_base64
    end while User.exists?(:auth_token => self[:auth_token])
  end

  # Make a convenience method for regenerating the token 
  # when we need it
  def regenerate_auth_token
    self.auth_token = nil
    generate_token
    save!
  end

  def self.full_name
    first_name + " " + last_name
  end
  
  def recent_posts
    self.posts.order("id DESC")
  end  
end