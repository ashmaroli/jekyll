# frozen_string_literal: true

module Jekyll
  module Tags
    class PostComparer
      MATCHER = %r!^(.+/)*(\d+-\d+-\d+)-(.*)$!.freeze

      attr_reader :path, :date, :slug, :name

      def initialize(name)
        @name = name

        all, @path, @date, @slug = *name.sub(%r!^/!, "").match(MATCHER)
        unless all
          raise Jekyll::Errors::InvalidPostNameError,
                "'#{name}' does not contain valid date and/or title."
        end

        escaped_slug = Regexp.escape(slug)
        @name_regex = %r!^_posts/#{path}#{date}-#{escaped_slug}\.[^.]+|
          ^#{path}_posts/?#{date}-#{escaped_slug}\.[^.]+!x
      end

      def post_date
        @post_date ||= Utils.parse_date(
          date,
          "'#{date}' does not contain valid date and/or title."
        )
      end

      def ==(other)
        other.relative_path.match(@name_regex)
      end

      def deprecated_equality(other)
        slug == post_slug(other) &&
          post_date.year  == other.date.year &&
          post_date.month == other.date.month &&
          post_date.day   == other.date.day
      end

      private

      # Construct the directory-aware post slug for a Jekyll::Post
      #
      # other - the Jekyll::Post
      #
      # Returns the post slug with the subdirectory (relative to _posts)
      def post_slug(other)
        path = other.basename.split("/")[0...-1].join("/")
        if path.nil? || path == ""
          other.data["slug"]
        else
          path + "/" + other.data["slug"]
        end
      end
    end

    class PostUrl < Liquid::Tag
      def initialize(tag_name, markup, parse_context)
        super
        @markup = markup.strip

        begin
          @comparer = PostComparer.new(@markup)
        rescue StandardError => error
          raise Jekyll::Errors::PostURLError, <<~MSG
            Could not parse name of post "#{@markup}" in tag 'post_url'.
            Make sure the post exists and the name is correct.

            #{error.class}: #{error.message}

          MSG
        end
      end

      def render(context)
        site = context.registers[:site]
        site.posts.docs.each do |post|
          return post.url if @comparer == post
        end

        # New matching method did not match, fall back to old method with deprecation warning
        # if this matches
        site.posts.docs.each do |post|
          next unless @comparer.deprecated_equality(post)

          # Use `Liquid::Tag#raw` to obtain the tag's name with markup
          Jekyll::Deprecator.deprecation_message "A call to '{% #{raw} %}' did not match a post " \
            "using the new matching method of checking name (path-date-slug) equality. Please " \
            "make sure that you change this tag to match the post's name exactly."
          return post.url
        end

        raise Jekyll::Errors::PostURLError, <<~MSG
          Could not find post "#{@markup}" in tag 'post_url'.
          Make sure the post exists and the name is correct.
        MSG
      end
    end
  end
end

Liquid::Template.register_tag("post_url", Jekyll::Tags::PostUrl)
