Gem::Specification.new do |s|
  s.name        = 'testi'
  s.summary     = 'Lightweight test framework'
  s.description = 'a minute and simple library for light TDD'
  s.version     = '0.0.1'
  s.platform    = Gem::Platform::RUBY
  s.date        = Time.now.to_date.to_s

  s.require_path = 'lib'
  s.extensions = Dir.glob('ext/**/extconf.rb')
  s.files = ['README.md'] +
            Dir.glob('lib/**/*.rb') +
            Dir.glob('testi/**/*.rb')
end
