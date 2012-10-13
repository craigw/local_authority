require "local_authority/version"
require "my_society/map_it"
require "csv"

module LocalAuthority
  class LocalAuthority
    DB_FILE = File.join File.dirname(__FILE__), '..', 'db', 'local_authorities.csv'
    DB = CSV.new File.read(DB_FILE), :headers => :first_row

    def self.all
      @all ||= DB.map { |row| new row.to_hash }
    end

    def self.find_by_map_it_id id
      all.detect { |la|
        la.map_it_id =~ /\/#{id}$/
      }
    end

    def self.find_by_postcode postcode
      p = MySociety::MapIt::Postcode.new postcode
      la = p.local_authority
      return if la.nil?
      find_by_map_it_id la.id
    end

    attr_accessor :attributes
    private :attributes=

    def initialize attributes
      self.attributes = attributes
    end

    def website
      attributes['Website']
    end

    def name
      attributes['Name']
    end

    def phone_number
      attributes['Phone Number']
    end

    def address
      attributes['Address']
    end

    def map_it_id
      attributes['MapIt ID']
    end
  end
end
