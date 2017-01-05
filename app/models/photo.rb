class Photo < ApplicationRecord
  include Shardable

  belongs_to :user
end
