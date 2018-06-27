# frozen_string_literal: true

module IsoBibItem
  #
  # Series class.
  #
  class Series
    # @return [String] allowed values: "main" or "alt"
    attr_reader :type

    # @return [IsoBibItem::FormattedString] title
    attr_reader :title

    # @return [String]
    attr_reader :place

    # @return [String]
    attr_reader :organization

    # @return [IsoBibItem::LocalizedString]
    attr_reader :abbreviation

    # @return [String] date or year
    attr_reader :from

    # @return [String] date or year
    attr_reader :to

    # @return [String]
    attr_reader :number

    # @return [String]
    attr_reader :part_number

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength

    # @param [Hash] **args <description>
    def initialize(**args)
      unless args[:title].is_a? IsoBibItem::FormattedString
        raise ArgumentError, 'Parametr `title` shoud present'
      end
      @type         = args[:type] if %w[main alt].include? args[:type]
      @title        = args[:title]
      @place        = args[:place]
      @organization = args[:organization]
      @abbreviation = args[:abbreviation]
      @from         = args[:from]
      @to           = args[:to]
      @number       = args[:number]
      @part_number  = args[:part_number]
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.series type: type do
        builder.title { title.to_xml builder } if title
        builder.place place if place
        builder.organization organization if organization
        builder.abbreviation { abbreviation.to_xml builder } if abbreviation
        builder.from from if from
        builder.to to if to
        builder.number number if number
        builder.part_number part_number if part_number
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
