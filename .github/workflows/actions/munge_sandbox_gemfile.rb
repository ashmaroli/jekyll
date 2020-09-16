# frozen_string_literal: true

SANDBOX_GEMFILE = File.expand_path('../../../../sandbox/Gemfile', __dir__)
CONTENTS = <<~RUBY
  source 'https://rubygems.org'

  gem 'jekyll', path: '../jekyll'

  group :jekyll_plugins do
    gem 'jekyll-mentions'
    gem 'jekyll-paginate'
    gem 'jekyll-redirect-from'
    gem 'jekyll-seo-tag'
    gem 'jekyll-seo'
    gem 'jekyll-sitemap'
  end

  gem 'memory_profiler'
RUBY

File.open(SANDBOX_GEMFILE, 'wb') { |f| f.puts(CONTENTS) }
File.open(File.expand_path('../../../../sandbox/Gemfile.lock', __dir__), "wb") { |f| f.puts "" }
