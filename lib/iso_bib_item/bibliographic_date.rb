# frozen_string_literal: true

require 'time'

module IsoBibItem
  # Bibliographic date.
  class BibliographicDate
    # @return [String]
    attr_reader :type

    # @return [Time]
    attr_reader :from

    # @return [Time]
    attr_reader :to

    # @param type [String] "published", "accessed", "created", "activated"
    # @param from [String]
    # @param to [String]
    def initialize(type:, from:, to: nil)
      @type = type
      @from = Time.strptime(from, '%Y-%d')
      @to   = Time.strptime(to, '%Y-%d') if to
    end

    def to_xml(builder, **opts)
      builder.date(type: type) do
        builder.from(opts[:no_year] ? '--' : from.year)
        builder.to to.year if to
      end
    end
  end
end
