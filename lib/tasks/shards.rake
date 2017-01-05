shards_namespace = namespace :shards do
  desc "Creates database shards"
  task create: [:environment] do
    Shard.config.each_pair do |shard, config|
      puts "== Creating shard #{shard}."
      ActiveRecord::Tasks::DatabaseTasks.create(config)
    end

    shards_namespace["schema:dump"].invoke
  end

  desc "Drops database shards"
    task drop: [:environment] do
    Shard.config.each_pair do |shard, config|
      puts "== Dropping shard #{shard}."
      ActiveRecord::Tasks::DatabaseTasks.drop(config)
    end
  end

  desc "Migrate the database."
  task migrate: [:environment] do
    Shard.config.each_pair do |shard, config|
      puts "== Migrating shard #{shard}."
      setup_migrations_path
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Tasks::DatabaseTasks.migrate
    end

    shards_namespace["schema:dump"].invoke
  end

  desc "Rolls the schema back to the previous version."
  task rollback: [:environment] do
    step = ENV["STEP"].try(:to_i) || 1

    Shard.config.each_pair do |shard, config|
      puts "== Rolling back shard #{shard}"
      setup_migrations_path
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Migrator.rollback(ActiveRecord::Tasks::DatabaseTasks.migrations_paths, step)
    end

    shards_namespace["schema:dump"].invoke
  end

  namespace :schema do
    desc "Creates a db/shards/schema.rb file that is portable against any DB supported by Active Record"
    task dump: [:environment] do
      require "active_record/schema_dumper"
      filename = File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "shards/schema.rb")
      File.open(filename, "w:utf-8") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
  end

  def setup_migrations_path
    migrations_dir = File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "shards/migrate")
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [migrations_dir]
    ActiveRecord::Migrator.migrations_paths = [migrations_dir]
  end
end
