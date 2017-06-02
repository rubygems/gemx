require 'gemx/version'

require 'optparse'
require 'rubygems'

# Execute a command that comes from a gem
module GemX
  X = Struct.new(:verbose, :gem_name, :requirements, :executable, :arguments)
  # The eXecutable part of this gem
  class X
    def install_if_needed
      activate!
    rescue Gem::MissingSpecError
      warn "#{dependency_to_s} not available locally" if verbose
      install
      activate!
    end

    def activate!
      gem(gem_name, *requirements)
    end

    def dependency_to_s
      if requirements.none?
        gem_name
      else
        "#{gem_name} (#{requirements})"
      end
    end

    def load!
      argv = ARGV.clone
      ARGV.replace arguments
      load Gem.activate_bin_path(gem_name, executable, '>= 0.a')
    rescue LoadError => e
      raise unless e.path.split(File::SEPARATOR).last == executable
      abort "Failed to load executable #{executable}," \
            " are you sure the gem #{gem_name} contains it?"
    ensure
      ARGV.replace argv
    end

    def self.parse!(args)
      options = new
      options.requirements = Gem::Requirement.new
      opt_parse = OptionParser.new do |opts|
        opts.program_name = 'gemx'
        opts.version = VERSION
        opts.banner = 'Usage: gemx [options --] command'

        opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
          options.verbose = v
        end

        opts.on('-g', '--gem=GEM',
                'Run the executable from the given gem') do |g|
          options.gem_name = g
        end

        opts.on('-r', '--requirement REQ',
                'Run the gem with the given requirement') do |r|
          options.requirements.concat [r]
        end
      end
      opt_parse.parse!(args) if args.first && args.first.start_with?('-')
      abort(opt_parse.help) if args.empty?
      options.executable = args.shift
      options.gem_name ||= options.executable
      options.arguments = args
      options
    end

    def self.run!(argv)
      parse!(argv).tap do |options|
        options.install_if_needed
        options.load!
      end
    end

    private

    def with_rubygems_config
      verbose_ = Gem.configuration.verbose
      Gem.configuration.verbose = verbose ? 1 : false
      yield
    ensure
      Gem.configuration.verbose = verbose_
    end

    def install
      with_rubygems_config do
        Gem.install(gem_name, requirements)
      end
    rescue => e
      abort "Installing #{dependency_to_s} failed:\n#{e.to_s.gsub(/^/, "\t")}"
    end
  end
end
