# frozen_string_literal: true

require 'iso_bib_item/organization'

module IsoBibItem
  # ISO project group.
  class IsoProjectGroup < Organization
    # @return [IsoBibItem::IsoSubgroup]
    attr_reader :technical_committee

    # @return [IsoBibItem::soSubgroup]
    attr_reader :subcommittee

    # @return [IsoBibItem::soSubgroup]
    attr_reader :workgroup

    # @return [String]
    attr_reader :secretariat

    # @param name [String]
    # @param url [String]
    # @param technical_commite [Hash{name=>String, type=>String,
    #   number=>Integer}]
    def initialize(name:, abbreviation: nil, url:, technical_committee:)
      super name: name, abbreviation: abbreviation, url: url
      @technical_committe = IsoSubgroup.new(technical_committee)
    end
  end

  # ISO subgroup.
  class IsoSubgroup
    # @return [String]
    attr_reader :type

    # @return [Integer]
    attr_reader :number

    # @return [String]
    attr_reader :name

    # @param name [String]
    # @param type [String]
    # @param number [Integer]
    def initialize(name:, type:, number:)
      @name   = name
      @type   = type
      @number = number
    end
  end
end
