# frozen_string_literal: true

require_relative 'lib/rspec_sql_counter/version'

Gem::Specification.new do |spec|
  spec.name = 'rspec_sql_counter'
  spec.version = RspecSqlCounter::VERSION
  spec.authors = ['Nastya Patutina']
  spec.email = ['npatutina@gmail.com']

  spec.summary = 'RSpec matcher for SQL queries'
  spec.description = 'RSpec matcher for SQL queries'
  spec.homepage = 'https://github.com/NastyaPatutina/rspec_sql_counter'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/NastyaPatutina/rspec_sql_counter'
  spec.metadata['changelog_uri'] = 'https://github.com/NastyaPatutina/rspec_sql_counter'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pg', '~> 1.4'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_runtime_dependency 'rails', '>= 4.0.13'
  spec.add_runtime_dependency 'rspec', '~> 3.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
