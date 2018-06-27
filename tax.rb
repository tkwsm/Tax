#!/usr/bin/ruby

module Node

  class TaxTree

    def initialize
      @tax_hash  = {}
      @name_hash = {}
      @name2_hash = {}
    end

    attr_reader :name_hash

    def add_taxdata( taxid, parent_taxid, taxtype)
      @td = TaxData.new( taxid, parent_taxid, taxtype )
      @tax_hash[ @td.taxid ] = @td
    end

    def add_namedata( taxid, name, description, nametype )
      @tn = NameData.new( taxid, name, description, nametype )
      @name_hash[ @tn.taxid ] = @tn
      @name2_hash[ @tn.name ] = @tn
    end

    def check_name_hash( taxid )
      @name_hash[ taxid ]
    end

    def show_taxtype( taxid )
      @tax_hash[ taxid ] 
    end

    def show_name( taxid )
      @name_hash[ taxid ].name 
    end

    def show_taxid_by_name( name )
      @name2_hash[ name ].taxid
    end

    def step_up_taxtree( taxid )
      taxid = taxid.to_i
      tax_path = []
      rep_level = ["varietas", "species", "genus", "family", "order", "class", "phylum", "kingdom", "superkingdom"]
      taxtype  = ""
      until taxtype == "superkingdom" or taxtype == nil
        parent_taxid = @tax_hash[ taxid ].parent_taxid
        taxtype      = @tax_hash[ taxid ].taxtype
        name         = @name_hash[ taxid ].name
        nametype     = @name_hash[ taxid ].nametype
        if rep_level.include?(taxtype)
          tax_path << [ taxid, taxtype, name, nametype ]
        end
        taxid = parent_taxid
      end
      return tax_path
    end

  end

  class TaxData

    def initialize( taxid, parent_taxid, taxtype)
      @taxid        = taxid
      @parent_taxid = parent_taxid
      @taxtype      = taxtype
    end

    attr_reader :taxid, :parent_taxid, :taxtype

  end

  class NameData

    def initialize( taxid, name, description, nametype )
      @taxid        = taxid
      @name         = name
      @description  = description
      @nametype     = nametype
    end

    attr_reader :taxid, :name, :nametype

  end

  def Node::parse_nodes( nodes_f, nt )
    nodes_h = {}
    a = []
    nodes_f.each do |x|
      a = x.chomp.split("\t")
      taxid        = a[0].to_i
      parent_taxid = a[2].to_i
      taxtype      = a[4]
      nt.add_taxdata( taxid, parent_taxid, taxtype)
    end
  end

  def Node::parse_names( names_f, nt )
    names_h = {}
    a = []
    names_f.each do |x|
      a = x.chomp.split("\t")
      taxid       = a[0].to_i
      name        = a[2]
      description = a[4]
      nametype    = a[6]
      if    nametype == "scientific name" 
        nt.add_namedata( taxid, name, description, nametype )
      elsif nametype == "synonym"     && nt.check_name_hash( taxid ) == nil
        nt.add_namedata( taxid, name, description, nametype )
      elsif nametype == "synonym"     && nt.check_name_hash( taxid ).nametype == "misspelling"
        nt.add_namedata( taxid, name, description, nametype )
      elsif nametype == "misspelling" && nt.check_name_hash( taxid ) == nil
        nt.add_namedata( taxid, name, description, nametype )
      end
    end
  end

end

if $0 == __FILE__

  if ARGV.size == 0
    print "\n"
    print "USAGE: please see the bottom of this script 'tax.rb'. \n"
    print "USAGE: or do as following\n"
    print " ruby tax.rb nodes.file names.file \n"
    print "\n"
    print "USAGE: If you are using this script on NIG super computer, \n"
    print " cp /usr/local/db/taxonomy/ncbi-taxonomy/taxdump.tar.gz ./ \n"
    print " Then, \n"
    print " gunzip Taxdump.tar.gz \n"
    print " tar xvf Taxdump.tar.gz \n"
    print " Then, \n"
    print " ruby tax.rb nodes.dmp names.dmp \n"
    print "\n"
    exit
  end

  nodes_f = open( ARGV.shift )
  names_f = open( ARGV.shift )

  nt = Node::TaxTree.new
  Node::parse_nodes( nodes_f, nt )
  Node::parse_names( names_f, nt )
  p "nt.show_name(2)"
  p nt.show_name(2)
  p "nt.show_name(11)"
  p nt.show_name(11)
  p "nt.show_taxtype(2)"
  p nt.show_taxtype(2)
  p "nt.step_up_taxtree(11)"
  p nt.step_up_taxtree( 11 )
  p "nt.show_taxid_by_name( \"Arabidopsis thaliana\" )"
  p nt.show_taxid_by_name( "Arabidopsis thaliana" )
  taxid = nt.show_taxid_by_name( "Arabidopsis thaliana" )
  p "nt.step_up_taxtree( taxid )"
  p nt.step_up_taxtree( taxid )

end
