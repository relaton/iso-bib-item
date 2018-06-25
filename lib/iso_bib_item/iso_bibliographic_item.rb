# frozen_string_literal: false

require 'nokogiri'
require 'isoics'
require 'duplicate'
require 'iso_bib_item/bibliographic_item'
require 'iso_bib_item/iso_document_status'
require 'iso_bib_item/iso_localized_title'
require 'iso_bib_item/iso_project_group'
require 'iso_bib_item/document_relation_collection'

# Add filter method to Array.
class Array
  def filter(type:)
    select { |e| e.type == type }
  end
end

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

    def remove_part
      @part_number = nil
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

    def to_xml(builder)
      builder.ics do
        builder.code code
        builder.text_ description
      end
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
        %i[
          id language script dates abstract contributors relations source
        ].include? k
      end
      super(super_args)
      @docidentifier = IsoDocumentId.new args[:docid]
      @edition       = args[:edition]
      @title         = args[:titles].map { |t| IsoLocalizedTitle.new(t) }
      @type          = args[:type]
      @status        = IsoDocumentStatus.new(args[:docstatus])
      @workgroup     = IsoProjectGroup.new(args[:workgroup]) if args[:workgroup]
      @ics = args[:ics].map { |i| Ics.new(i) }
      @copyright = CopyrightAssociation.new args[:copyright] if args[:copyright]
      @source = args[:source].map { |s| TypedUri.new(s) }
      @id_attribute = true
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    
    def disable_id_attribute
      @id_attribute = false
    end
  
    # convert ISO nnn-1 reference into an All Parts reference: 
    # remove title part components and abstract  
    def to_all_parts
      me = Duplicate.duplicate(self)
      me.disable_id_attribute
      @relations << DocumentRelation.new(type: "partOf", identifier: nil, url: nil, bibitem: me)

      @title.each(&:remove_part)
      @abstract = []
      @docidentifier.remove_part
      @all_parts = true
    end

    # convert ISO:yyyy reference to reference to most recent
    # instance of reference, removing date-specific infomration:
    # date of publication, abstracts. Make dated reference Instance relation
    # of the redacated document
    def to_most_recent_reference
      me = Duplicate.duplicate(self)
      me.disable_id_attribute
      @relations << DocumentRelation.new(type: "instance", identifier: nil, url: nil, bibitem: me)
      @abstract = []
      @dates = []
    end

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
    def to_xml(builder = nil, **opts, &block)
      if builder
        render_xml builder, opts, &block
      else
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          render_xml xml, opts, &block
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
      return nil unless @id_attribute
      contribs = publishers.map { |p| p&.entity&.abbreviation }.join '/'
      idstr = "#{contribs}#{delim}#{@docidentifier.project_number}"
      if @docidentifier.part_number&.size&.positive?
        idstr << "-#{@docidentifier.part_number}"
      end
      idstr.strip
    end

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
        builder.edition edition if edition
        language.each { |l| builder.language l }
        script.each { |s| builder.script s }
        abstract.each { |a| builder.abstract { a.to_xml(builder) } }
        status.to_xml builder
        copyright&.to_xml builder
        relations.each { |r| r.to_xml builder }
        if opts[:note]
          builder.note("ISO DATE: #{opts[:note]}", format: 'text/plain')
        end
        ics.each { |i| i.to_xml builder }
        builder.allParts 'true' if @all_parts
        yield(builder) if block_given?
      end
    end
  end
end
