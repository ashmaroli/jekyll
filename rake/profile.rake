# frozen_string_literal: true

namespace :profile do
  require "jekyll"

  desc "Usage instructions for profile:class task"
  task :help do
    Jekyll.logger.info <<~HELP
      ------------------------------------ USAGE ------------------------------------
        The tasks in this namespace will profile methods and instance methods in a
        given class (Jekyll::Site) by default by building the documentation site
        source directory.

        The aim of this set of Rake tasks is to guage the amount of time Jekyll
        spends across various methods within a given Class while building a source
        with numerous posts, plugins and other assets.

        To benchmark `Jekyll::Site` simply run the following:

          bundle exec rake profile:class

        To profile another class say, `Jekyll::Renderer` simply pass the class name

          bundle exec rake profile:class[Renderer]

        Wanna profile a deeper class? No probs..

          bundle exec rake profile:class[Converters::Kramdown]

      -------------------------------------------------------------------------------
    HELP
  end

  desc "Profile methods in given class during a build session"
  task :class, [:name] do |_t, args|
    require "method_profiler"
    require "classifier-reborn"

    args.with_defaults(:name => "Cleaner")

    subject = args.name
    klass   = Object.const_get(subject, false)

    profiler = MethodProfiler.observe(klass)
    Jekyll.logger.info "-" * 80
    Jekyll.logger.info "Profiling:", klass.name.cyan
    Jekyll.logger.info "-" * 80

    Jekyll::Commands::Build.process(
      "source"      => File.expand_path("docs"),
      "destination" => File.expand_path("docs/_site"),
      "verbose"     => false,
      "trace"       => true,
    )

    Jekyll.logger.info ""
    Jekyll.logger.info profiler.report.sort_by(:method).order(:descending)
  end
end
