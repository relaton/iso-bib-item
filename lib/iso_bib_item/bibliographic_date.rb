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

    # @return [Time]
    attr_reader :on

    # @param type [String] "published", "accessed", "created", "activated"
    # @param from [String]
    # @param to [String]
    def initialize(type:, on: nil, from: nil, to: nil)
      raise ArgumentError, 'expected :on or :form argument' unless on || from
      @type = type
      @on   = Time.strptime(on, '%Y-%d') if on
      @from = Time.strptime(from, '%Y-%d') if from
      @to   = Time.strptime(to, '%Y-%d') if to
    end

    def to_xml(builder, **opts)
      builder.date(type: type) do
        if on
          builder.on(opts[:no_year] ? '--' : on.year)
        else
          builder.from(opts[:no_year] ? '--' : from.year)
          builder.to to.year if to
        end
      end
    end
  end
end
