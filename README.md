# RSpec SQL Counter

Welcome to rspec_sql_counter gem!

It helps you to test SQL queries, that are called in code blocks.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec_sql_counter'
```

And then execute:

    bundle install

Or install it yourself as:

    gem install rspec_sql_counter

## Usage
Add to `rails_helper.rb` or your spec-file:

    require 'rspec_sql_counter'

To test that query called in method, add this code on your it-block:

    expect { ReportGenerator.call }.to call_sql_query('SELECT COUNT(*) FROM "users"')

Also to test query not called in method use:

    expect { ReportGenerator.call }.not_to call_sql_query('SELECT COUNT(*) FROM "users"')

You can restrict the matcher using times counter:

    expect { ReportGenerator.call }.to call_sql_query('SELECT COUNT(*) FROM "users"').times(2)

You can restrict the matcher using bind values:

    expect { ReportGenerator.call }.to call_sql_query('SELECT "users".* FROM "users" WHERE "users"."name" = $1').with('Karl')

Below is an example of a description of an error in tests

```
 Expected to call SQL query SELECT "companies".* FROM "companies" LIMIT $1 OFFSET $2 with values [1, 2] 1 times, but found this queries:
    3 times: SELECT COUNT(*) FROM "companies"
    1 times: SELECT COUNT(*) FROM (SELECT 1 AS one FROM "companies" LIMIT $1 OFFSET $2) subquery_for_count with values [5, 10]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/NastyaPatutina/rspec_sql_counter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/NastyaPatutina/rspec_sql_counter/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RspecSqlCounter project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/NastyaPatutina/rspec_sql_counter/blob/main/CODE_OF_CONDUCT.md).
