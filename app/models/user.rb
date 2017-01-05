class User < ApplicationRecord
  include Shardable

  has_many :photos

end
