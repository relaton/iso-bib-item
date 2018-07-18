# frozen_string_literal: true

require 'iso_bib_item/organization'

module IsoBibItem
  # ISO project group.
  class IsoProjectGroup
    # @return [IsoBibItem::IsoSubgroup]
    attr_reader :technical_committee

    # @return [IsoBibItem::IsoSubgroup]
    attr_reader :subcommittee

    # @return [IsoBibItem::IsoSubgroup]
    attr_reader :workgroup

    # @return [String]
    attr_reader :secretariat

    # @param name [String]
    # @param url [String]
    # @param technical_commite [Hash{name=>String, type=>String,
    #   number=>Integer}]
    # @param subcommittee [IsoBibItem::IsoSubgroup]
    # @param workgroup [IsoBibItem::IsoSubgroup]
    # @param secretariat [String]
    def initialize(technical_committee:, **args)
      @technical_committee = if technical_committee.is_a? Hash
                               IsoSubgroup.new(technical_committee)
                             else technical_committee end
      @subcommittee        = args[:subcommittee]
      @workgroup           = args[:workgroup]
      @secretariat         = args[:secretariat]
    end

    # rubocop:disable Metrics/AbcSize

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.editorialgroup do
        builder.technical_committee { technical_committee.to_xml builder } if technical_committee
        builder.subcommittee { subcommittee.to_xml builder } if subcommittee
        builder.workgroup { workgroup.to_xml builder } if workgroup
        builder.secretariat secretariat if secretariat
      end
    end
    # rubocop:enable Metrics/AbcSize
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
    def initialize(name:, type: nil, number: nil)
      @name   = name
      @type   = type
      @number = number
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.parent[:number] = number if number
      builder.parent[:type] = type if type
      builder.text name
    end
  end
end
