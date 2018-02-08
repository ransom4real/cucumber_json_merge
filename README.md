# Cucumber Json Merge

Merges two or more Cucumber JSON reports, such that results from the source JSON file overwrites the results on the target JSON file. Reports may be single files or directory trees.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_merge'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json_merge

## Usage

Run:

```bash
cucumber_json_merge SOURCE.json SOURCE2.json ... TARGET.json
```

Test results in the source JSON matching any results in the target JSON will overwrite them. If they are not existent in the target JSON then they will be appended to the target JSON file

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ransom4real/json_merge. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

