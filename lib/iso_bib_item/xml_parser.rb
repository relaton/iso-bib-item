require 'nokogiri'

module IsoBibItem
  class XMLParser
    class << self
      def from_xml(xml)
        doc = Nokogiri::XML(xml)
        IsoBibliographicItem.new( 
          docid:        fetch_docid(doc),
          edition:      doc.at('/bibitem/edition')&.text,
          language:     doc.xpath('/bibitem/language').map(&:text),
          script:       doc.xpath('/bibitem/script').map(&:text),
          titles:       fetch_titles(doc),
          type:         doc.at('bibitem')&.attr(:type),
          docstatus:    fetch_status(doc),
          ics:          fetch_ics(doc),
          dates:        fetch_dates(doc),
          contributors: fetch_contributors(doc),
          workgroup:    fetch_workgroup(doc),
          abstract:     fetch_abstract(doc),
          copyright:    fetch_copyright(doc),
          link:         fetch_link(doc),
          relations:    fetch_relations(doc)
        )
      end

      private

      def get_id(did)
        did.text.match(/^(?<project>.*?\d+)(?<hyphen>-)?(?(<hyphen>)(?<part>\d*))/)
      end

      def fetch_docid(doc)
        ret = []
        doc.xpath("/bibitem/docidentifier").each do |did|
          #did = doc.at('/bibitem/docidentifier')
          type = did.at("./@type")
          if did.text == "IEV" then ret << IsoBibItem::IsoDocumentId.new(project_number: "IEV", part_number: nil, prefix: nil)
          else
            id = get_id did
            ret << IsoBibItem::IsoDocumentId.new(project_number: id.nil? ? did.text : id[:project],
                                                 part_number:    (id.nil? || !id.names.include?("part")) ? nil : id[:part],
                                                 prefix:         nil,
                                                 id:             did.text,
                                                 type:           type&.text)
          end
        end
        ret
      end

      def fetch_titles(doc)
        doc.xpath("/bibitem/title").map do |t|
          titl = t.text.sub("[ -- ]", "").split " -- "
          case titl.size
          when 0
            intro, main, part = nil, "", nil
          when 1
            intro, main, part = nil, titl[0], nil
          when 2
            if /^(Part|Partie) \d+:/.match titl[1]
              intro, main, part = nil, titl[0], titl[1]
            else
              intro, main, part = titl[0], titl[1], nil
            end
          when 3
            intro, main, part = titl[0], titl[1], titl[2]
          else
            intro, main, part = titl[0], titl[1], titl[2..-1]&.join(" -- ")
          end
          IsoLocalizedTitle.new(title_intro: intro, title_main: main,
                                title_part: part, language: t[:language],
                                script: t[:script])
        end
      end

      def fetch_status(doc)
        status    = doc.at('/bibitem/status')
        stage     = status&.at('stage')&.text
        substage  = status&.at('substage')&.text
        iteration = status&.at('iterarion')&.text&.to_i
        IsoDocumentStatus.new(status: status&.text, stage: stage,
                              substage: substage, iteration: iteration)
      end

      def fetch_ics(doc)
        doc.xpath('/bibitem/ics/code').map { |ics| Ics.new ics.text }
      end

      def fetch_dates(doc)
        doc.xpath('/bibitem/date').map do |d|
          BibliographicDate.new(type: d[:type], on: d.at('on')&.text,
                                from: d.at('from')&.text,
                                to: d.at('to')&.text)
        end
      end

      def get_org(org)
        names = org.xpath("name").map do |n|
          { content: n.text, language: n[:language], script: n[:script] }
        end
        identifiers = org.xpath("./identifier").map do |i|
          IsoBibItem::OrgIdentifier.new(i[:type], i.text)
        end
        IsoBibItem::Organization.new(name: names,
                                     abbreviation: org.at("abbreviation")&.text,
                                     url: org.at("uri")&.text,
                                     identifiers: identifiers)
      end

      def get_person(person)
        name = person.at "./name/completename"
        affilations = person.xpath("./affiliation").map do |a|
          org = a.at "./organization"
          IsoBibItem::Affilation.new get_org(org)
        end

        contacts = person.xpath("./address | ./phone | ./email | ./uri").map do |contact|
          if contact.name == "address"
            streets = contact.xpath("./street").map(&:text)
            IsoBibItem::Address.new(
              street: streets,
              city: contact.at("./city").text,
              state: contact.at("./state").text,
              country: contact.at("./country").text,
              postcode: contact.at("./postcode").text,
            )
          else
            IsoBibItem::Contact.new(type: contact.name, value: contact.text)
          end
        end

        identifiers = person.xpath("./identifier").map do |pi|
          IsoBibItem::PersonIdentifier.new pi[:type], pi.text
        end

        completename = IsoBibItem::LocalizedString.new(name.text, name[:language])
        IsoBibItem::Person.new(
          name: IsoBibItem::FullName.new(completename: completename),
          affiliation: affilations,
          contacts: contacts,
          identifiers: identifiers,
        )
      end

      def fetch_contributors(doc)
        doc.xpath("/bibitem/contributor").map do |c|
          entity = if (org = c.at "./organization") then get_org(org)
                   elsif (person = c.at "./person") then get_person(person)
                   end
          role_descr = c.xpath("./role/description").map &:text
          IsoBibItem::ContributionInfo.new entity: entity,
                                           role: [[c.at("role")[:type], role_descr]]
        end
      end

      # @TODO Organization doesn't recreated
      def fetch_workgroup(doc)
        eg = doc.at('/bibitem/editorialgroup')
        tc = eg&.at('technical_committee')
        sc = eg&.at('subcommittee')
        scom = iso_subgroup(sc)
        wg   = eg&.at('workgroup')
        wgrp = iso_subgroup(wg)
        IsoProjectGroup.new(technical_committee: iso_subgroup(tc),
                            subcommittee: scom, workgroup: wgrp)
      end

      def iso_subgroup(com)
        return nil if com.nil?
        IsoSubgroup.new(name: com.text, type: com[:type],
                        number: com[:number].to_i)
      end

      def fetch_abstract(doc)
        doc.xpath('/bibitem/abstract').map do |a|
          FormattedString.new(content: a.text, language: a[:language],
                              script: a[:script], type: a[:format])
        end
      end

      def fetch_copyright(doc)
        cp     = doc.at('/bibitem/copyright') || return
        org    = cp&.at('owner/organization')
        name   = org&.at('name').text
        abbr   = org&.at('abbreviation')&.text
        url    = org&.at('uri')&.text
        entity = Organization.new(name: name, abbreviation: abbr, url: url)
        from   = cp.at('from')&.text
        to     = cp.at('to')&.text
        owner  = ContributionInfo.new entity: entity
        CopyrightAssociation.new(owner: owner, from: from, to: to)
      end

      def fetch_link(doc)
        doc.xpath('/bibitem/uri').map do |l|
          TypedUri.new type: l[:type], content: l.text
        end
      end

      def fetch_relations(doc)
        doc.xpath("/bibitem/relation").map do |r|
          localities = r.xpath("./locality").map do |l|
            ref_to = (rt = l.at("./referenceTo")) ? LocalizedString.new(rt.text) : nil
            BibItemLocality.new(
              l[:type],
              LocalizedString.new(l.at("./referenceFrom").text),
              ref_to
            )
          end
          DocumentRelation.new(
            type: r[:type],
            identifier: r&.at("./bibitem/formattedref | ./bibitem/docidentifier")&.text,
            bib_locality: localities,
          )
        end
      end
    end
  end
end
