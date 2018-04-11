Gem::Specification.new do |spec|
  spec.name          = 'gemx'
  spec.version       = File.read(File.expand_path('../VERSION', __FILE__))
                           .strip.freeze
  spec.authors       = ['Samuel Giddins']
  spec.email         = ['segiddins@segiddins.me']

  spec.summary       = 'Automagically execute commands that come in gem form'

  spec.homepage      = 'https://github.com/segiddins/gemx'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.51.0'

  spec.required_ruby_version     = '>= 2'
  spec.required_rubygems_version = '>= 2.6.10'
end
