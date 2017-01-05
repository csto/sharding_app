module Shardable
  extend ActiveSupport::Concern

  class_methods do
    def connection
      Shard.connection_manager.current_connection
    end
  end

  included do
    def shard(uuid)
      shard_number = logical_shard(uuid) % Shard.config.count
      "shard#{shard_number}".to_sym
    end

    private

    def logical_shard(uuid)
      uuid[0..2].to_i(16)
    end
  end
end
