# GemX

Ever wanted it to be easier to run a command that just so happens to come as a
gem? Yeah, @indirect too. So he nerd-sniped me into building this.

## Installation

    $ gem install gemx

## Usage

```shell
$ gemx rails new .
$ gemx --gem cocoapods -r '> 1' -r '< 1.3' -v -- pod install --no-color --help
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bin/rake install`. To release a new version, update the version number in `version.rb`, and then run `bin/rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/segiddins/gemx. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gemx project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/segiddins/gemx/blob/master/CODE_OF_CONDUCT.md).
