class Shard
  def self.config
    @shard_config ||= YAML.load_file("#{Rails.root}/config/shards.yml")[Rails.env]
  end

  def self.connection_manager
    @connection_manager ||= Octoshark::ConnectionPoolsManager.new(config)
  end

  def self.using(shard)
    connection_manager.with_connection(shard) do
      result = yield
      result = result.records if result.respond_to?(:records)
    end
  end

  def self.using_all
    results = []

    config.each_pair do |shard, _|
      results << using(shard) do
        yield
      end
    end

    results.flatten
  end
end
