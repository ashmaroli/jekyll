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
RUBY

File.open(SANDBOX_GEMFILE, 'wb') { |f| f.puts(CONTENTS) }
