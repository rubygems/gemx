require 'gemx/version'

require 'optparse'
require 'rubygems'

# Execute a command that comes from a gem
module GemX
  X = Struct.new(
    :gem_name,
    :requirements,
    :executable,
    :arguments,
    :conservative,
    :verbose
  )

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
      Gem.finish_resolve
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

      exe = executable

      contains_executable = Gem.loaded_specs.values.select do |spec|
        spec.executables.include?(executable)
      end

      if contains_executable.any? { |s| s.name == executable }
        contains_executable.select! { |s| s.name == executable }
      end

      if contains_executable.empty?
        if (spec = Gem.loaded_specs[executable]) && (exe = spec.executable)
          contains_executable << spec
        else
          abort "Failed to load executable #{executable}," \
                " are you sure the gem #{gem_name} contains it?"
        end
      end

      if contains_executable.size > 1
        abort "Ambiguous which gem `#{executable}` should come from: " \
              "the options are #{contains_executable.map(&:name)}, " \
              'specify one via `-g`'
      end

      load Gem.activate_bin_path(contains_executable.first.name, exe, '>= 0.a')
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

        opts.on_tail('-v', '--[no-]verbose', 'Run verbosely') do |v|
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

        opts.on('--pre',
                'Allow resolving pre-release versions of the gem') do |_r|
          options.requirements.concat ['>= 0.a']
        end

        opts.on('-c', '--[no-]conservative',
                'Prefer the most recent installed version, ' \
                'rather than the latest version overall') do |c|
          options.conservative = c
        end
      end
      opt_parse.parse!(args) if args.first && args.first.start_with?('-')
      abort(opt_parse.help) if args.empty?
      options.executable = args.shift
      options.gem_name ||= options.executable
      options.arguments = args
      options.requirements.requirements.tap(&:uniq).delete(['>=', Gem::Version.new('0')])

      options
    end

    def self.run!(argv)
      parse!(argv).run!
    end

    def run!
      print_command if verbose
      if conservative
        install_if_needed
      else
        install
        activate!
      end

      load!
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
      home = Gem.paths.home
      home = File.join(home, 'gemx')
      Gem.use_paths(home, Gem.path + [home])
      with_rubygems_config do
        Gem.install(gem_name, requirements)
      end
    rescue StandardError => e
      abort "Installing #{dependency_to_s} failed:\n#{e.to_s.gsub(/^/, "\t")}"
    end

    def print_command
      puts "running gemx with:\n"
      opts = to_h.reject { |_, v| v.nil? }
      max_length = opts.map { |k, _| k.size }.max
      opts.each do |k, v|
        next if v.nil?
        puts "\t#{k.to_s.rjust(max_length)}: #{v} "
      end
      puts
    end
  end
end
