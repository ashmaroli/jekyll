# frozen_string_literal: true

SANDBOX_GEMFILE = File.expand_path('../../../../sandbox/Gemfile', __dir__)
contents = File.read(SANDBOX_GEMFILE).gsub(%r!gem 'jekyll'(.*)!, "gem 'jekyll', path: '../jekyll'")
File.open(SANDBOX_GEMFILE, 'wb') { |f| f.puts(contents) }
