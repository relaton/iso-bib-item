# frozen_string_literal: true

require 'iso_bib_item/contributor'

module IsoBibItem
  # Person's full name
  class FullName
    # @return [Array<IsoBibItem::LocalizedString>]
    attr_accessor :forenames

    # @return [Array<IsoBibItem::LocalizedString>]
    attr_accessor :initials

    # @return [IsoBibItem::LocalizedString]
    attr_accessor :surname

    # @return [Array<IsoBibItem::LocalizedString>]
    attr_accessor :additions

    # @return [Array<IsoBibItem::LocalizedString>]
    attr_accessor :prefix

    # @return [IsoBibItem::LocalizedString]
    attr_reader :completename

    # @param surname [IsoBibItem::LocalizedString]
    # @param forenames [Array<IsoBibItem::LocalizedString>]
    # @param initials [Array<IsoBibItem::LocalizedString>]
    # @param prefix [Array<IsoBibItem::LocalizedString>]
    # @param completename [IsoBibItem::LocalizedString]
    def initialize(**args)
      unless args[:surname] || args[:completename]
        raise ArgumentError, 'Should be given :surname or :completename'
      end
      @surname      = args[:surname]
      @forenames    = args[:forenames]
      @initials     = args[:initials]
      @additions    = args[:additions]
      @prefix       = args[:prefix]
      @completename = args[:completename]
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.name do
        if completename
          builder.completename { completename.to_xml builder }
        else
          builder.prefix { prefix.each { |p| p.to_xml builder } } if prefix
          builder.initial { initials.each { |i| i.to_xml builder } } if initials
          builder.addition { additions.each { |a| a.to_xml builder } } if additions
          builder.surname { surname.to_xml builder }
          builder.forename { forenames.each { |f| f.to_xml builder } } if forenames
        end
      end
    end
  end

  module PersonIdentifierType
    ISNI = 'isni'
    URI  = 'uri'
  end

  # Person identifier.
  class PersonIdentifier
    # @return [PersonIdentifierType]
    attr_accessor :type

    # @return [String]
    attr_accessor :value

    def initialize(type, value)
      @type  = type
      @value = value
    end
  end

  # Person class.
  class Person < Contributor
    # @return [IsoBibItem::FullName]
    attr_accessor :name

    # @return [Array<IsoBibItem::Affilation>]
    attr_accessor :affilation

    # @return [Array<IsoBibItem::PersonIdentifier>]
    attr_accessor :identifiers

    # @param name [IsoBibItem::FullName]
    # @param affilation [Array<IsoBibItem::Affilation>]
    def initialize(name:, affilation: [], contacts:)
      super(contacts: contacts)
      @name        = name
      @affilation  = affilation
      @identifiers = []
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.person do
        name.to_xml builder
        affilation.each { |a| a.to_xml builder }
        contacts.each { |contact| contact.to_xml builder }
      end
    end
  end
end
