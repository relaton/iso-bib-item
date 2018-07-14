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
      @on   = parse_date on
      @from = parse_date from
      @to   = parse_date to
    end

    # rubocop:disable Metric/AbcSize

    # @param builder [Nokogiri::XML::Builder]
    # @return [Nokogiri::XML::Builder]
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
    # rubocop:enable Metric/AbcSize

    private

    # @params date [String] 'yyyy' or 'yyyy-mm'
    def parse_date(date)
      return unless date
      if date =~ /\d{4}/
        Time.strptime date, '%Y'
      else
        Time.strptime date, '%Y-%m'
      end
    end
  end
end
