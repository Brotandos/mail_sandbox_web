class User::Facebook < ActiveRecord::Base
  belongs_to :user
  attr_accessible :uid

  validates :uid, :presence => true, :uniqueness => true
end
