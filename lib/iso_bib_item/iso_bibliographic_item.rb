# frozen_string_literal: false

require 'nokogiri'
require 'isoics'
require 'iso_bib_item/bibliographic_item'
require 'iso_bib_item/iso_document_status'
require 'iso_bib_item/iso_localized_title'
require 'iso_bib_item/iso_project_group'
require 'iso_bib_item/document_relation_collection'

# Add filter method to Array.
# class Array
#   def filter(type:)
#     select { |e| e.type == type }
#   end
# end

module IsoBibItem
  # Iso document id.
  class IsoDocumentId
    # @return [Integer]
    attr_reader :tc_document_number

    # @return [Integer]
    attr_reader :project_number

    # @return [Integer]
    attr_reader :part_number

    # @param project_number [Integer]
    # @param part_number [Integer]
    def initialize(project_number:, part_number:)
      @project_number = project_number
      @part_number    = part_number
    end

    def to_xml(builder)
      builder.docidentifier(project_number + '-' + part_number)
    end
  end

  # module IsoDocumentType
  #   INTERNATIONAL_STANDART           = "internationalStandard"
  #   TECHNICAL_SPECIFICATION          = "techinicalSpecification"
  #   TECHNICAL_REPORT                 = "technicalReport"
  #   PUPLICLY_AVAILABLE_SPECIFICATION = "publiclyAvailableSpecification"
  #   INTERNATIONAL_WORKSHOP_AGREEMENT = "internationalWorkshopAgreement"
  # end

  # Iso ICS classificator.
  class Ics < Isoics::ICS
    # @param field [Integer]
    # @param group [Integer]
    # @param subgroup [Integer]
    def initialize(field:, group:, subgroup:)
      super fieldcode: field, groupcode: group, subgroupcode: subgroup
    end
  end

  # Bibliographic item.
  class IsoBibliographicItem < BibliographicItem
    # @return [IsoBibItem::IsoDocumentId]
    attr_reader :docidentifier

    # @return [String]
    attr_reader :edition

    # @!attribute [r] title
    #   @return [Array<IsoBibItem::IsoLocalizedTitle>]

    # @return [IsoBibItem::IsoDocumentType]
    attr_reader :type

    # @return [IsoBibItem::IsoDocumentStatus]
    attr_reader :status

    # @return [IsoBibItem::IsoProjectGroup]
    attr_reader :workgroup

    # @return [Array<IsoBibItem::Ics>]
    attr_reader :ics

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # @param docid [Hash{project_number=>Integer, part_number=>Integer}]
    # @param titles [Array<Hash{title_intro=>String, title_main=>String,
    #   title_part=>String, language=>String, script=>String}>]
    # @param edition [String]
    # @param language [Array<String>]
    # @param script [Arrra<String>]
    # @param type [String]
    # @param docstatus [Hash{status=>String, stage=>String, substage=>String}]
    # @param workgroup [Hash{name=>String, abbreviation=>String, url=>String,
    #   technical_committee=>Hash{name=>String, type=>String, number=>Integer}}]
    # @param ics [Array<Hash{field=>Integer, group=>Integer,
    #   subgroup=>Integer}>]
    # @param dates [Array<Hash{type=>String, from=>String, to=>String}>]
    # @param abstract [Array<Hash{content=>String, language=>String,
    #   script=>String, type=>String}>]
    # @param contributors [Array<Hash{entity=>Hash{name=>String, url=>String,
    #   abbreviation=>String}, roles=>Array<String>}>]
    # @param copyright [Hash{owner=>Hash{name=>String, abbreviation=>String,
    #   url=>String}, form=>String, to=>String}]
    # @param source [Array<Hash{type=>String, content=>String}>]
    # @param relations [Array<Hash{type=>String, identifier=>String}>]
    def initialize(**args)
      super_args = args.select do |k|
        %i[language script dates abstract contributors relations].include? k
      end
      super(super_args)
      @docidentifier = IsoDocumentId.new args[:docid]
      @edition       = args[:edition]
      @title         = args[:titles].map { |t| IsoLocalizedTitle.new(t) }
      @type          = args[:type]
      @status        = IsoDocumentStatus.new(args[:docstatus])
      @workgroup     = IsoProjectGroup.new(args[:workgroup]) if args[:workgroup]
      @ics = args[:ics].map { |i| Ics.new(i) }
      if args[:copyright]
        @copyright = CopyrightAssociation.new(args[:copyright])
      end
      @source = args[:source].map { |s| TypedUri.new(s) }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # @param lang [String] language code Iso639
    # @return [IsoBibItem::IsoLocalizedTitle]
    def title(lang: nil)
      if lang
        @title.find { |t| t.language == lang }
      else
        @title 
      end
    end

    # @todo need to add ISO/IEC/IEEE
    # @return [String]
    def shortref(**opts)
      year = if opts[:all_parts] then ':All Parts'
             elsif opts[:no_year] then ''
             else ':' + @copyright.from&.year&.to_s
             end

      "#{id(' ')}#{year}"
    end

    # @param type [Symbol] type of url, can be :src/:obp/:rss
    # @return [String]
    def url(type = :src)
      @source.find { |s| s.type == type.to_s }.content.to_s
    end

    # @return [String]
    def to_xml(builder = nil, **opts)
      if builder
        render_xml builder, opts
      else
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          render_xml xml, opts
        end.doc.root.to_xml
      end
    end

    private

    def publishers
      @contributors.select do |c|
        c.role.select { |r| r.type == 'publisher' }.any?
      end
    end

    def id(delim = '')
      contribs = publishers.map { |p| p&.entity&.abbreviation }.join '/'
      idstr = "#{contribs}#{delim}#{@docidentifier.project_number}"
      if @docidentifier.part_number&.size&.positive?
        idstr << "-#{@docidentifier.part_number}"
      end
      idstr
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def render_xml(builder, **opts)
      builder.send(:bibitem, type: type, id: id) do
        title.each { |t| t.to_xml builder }
        source.each { |s| s.to_xml builder }
        # docidentifier.to_xml builder
        builder.docidentifier shortref(opts.merge(no_year: true))
        dates.each { |d| d.to_xml builder, opts }
        contributors.each do |c|
          builder.contributor do
            c.role.each { |r| r.to_xml builder }
            c.to_xml builder
          end
        end
        builder.edition edition
        language.each { |l| builder.language l }
        script.each { |s| builder.script s }
        abstract.each { |a| builder.abstract { a.to_xml(builder) } }
        status.to_xml builder
        copyright&.to_xml builder
        relations.each { |r| r.to_xml builder }
        if opts[:note]
          builder.note("ISO DATE: #{opts[:note]}", format: 'text/plain')
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
