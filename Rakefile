#!/usr/bin/env rake
require "bundler/gem_tasks"

DB_FILE = File.join File.dirname(__FILE__), 'db', 'local_authorities.csv'
HEADERS = [ "Name", "Contact Point", "Address", "Phone Number", "Fax", "Website", "Opening House", "DirectGov ID", "MapIt ID" ]

require 'net/http'
require 'nokogiri'
require 'uri'
require 'csv'
require 'my_society/map_it'
require 'timeout'
require 'fileutils'

def fetch href
  begin
    # puts href
    Timeout.timeout 10 do
      r = Net::HTTP.get_response URI.parse href
      while r['Location']
	# puts " => #{r['Location']}"
	r = Net::HTTP.get_response URI.parse r['Location']
      end
      r
    end
  rescue Timeout::Error
    puts "Retry"
    retry
  end
end

task :local_authorities do
  CSV.open DB_FILE, 'w' do |csv|
    csv << HEADERS
    A_TO_Z = 'http://www.direct.gov.uk/en/Dl1/Directories/Localcouncils/AToZOfLocalCouncils/DG_A-Z_LG'
    r = Net::HTTP.get_response URI.parse A_TO_Z
    doc = Nokogiri::HTML r.body
    links = doc.xpath "//ul[@class='atoz']/li/a"
    links.to_a.each do |anchor|
      puts "Generating local authorities beginning with #{anchor.inner_text.to_s.strip}..."
      href = [ A_TO_Z, anchor['href'] ].join
      r = fetch href
      doc = Nokogiri::HTML r.body
      authorities = doc.xpath "//ul[@class='atoz']/../../div[@class='subContent']/div[@class='subContent']"
      authorities.to_a.each do |a|
	info_link = a.at_xpath("./ul[@class='subLinks']/li/a")
	href = [ 'http://www.direct.gov.uk', info_link['href'] ].join
	r = fetch href
	doc = Nokogiri::HTML r.body
	info = doc.xpath(".//div[@class='subContent']")
	attributes = {
	  :title => info.xpath("./h3").inner_text.to_s.strip,
          :direct_gov_id => href
	}
        next if attributes[:title].to_s.strip == ""
        puts "  - #{attributes[:title]}"
	info.xpath(".//li").to_a.each do |li|
	  key = li.xpath(".//div[@class='headingContainer']").inner_text.to_s.strip
	  key.gsub! /\s*\(opens new window\)\s*/, ''
	  key.downcase!
	  key.gsub! /\s+/, '_'
	  k = key.to_sym
	  value_node = li.xpath(".//div[@class='infoContainer']")
	  value = case k
	  when :website, :opening_hours, :email_address, :contact_point
	    value_node.inner_text.to_s.strip
	  when :phone_number, :fax
	    value_node.xpath(".//strong").remove
	    value_node.xpath(".//span").children.to_a.map { |number| number.inner_text.to_s.strip.gsub(/\s+/, '') }.select { |number| number != "" }[0]
	  when :address
	    address_html = value_node.at_xpath(".//span").inner_html
	    address_html.split(/\<br\>/).map { |s| s.strip }.join("\n")
	  else
	    next
	  end
	  attributes[k] = value
	end

        csv << attributes.values_at(:title, :contact_point, :address, :phone_number, :fax, :website, :opening_hours, :direct_gov_id, :map_it_id)
      end
    end
  end
end

desc "Connect the local authority database to MapIt"
task :map_it do
  TMP_FILE = DB_FILE + '.tmp'
  CSV.open TMP_FILE, 'wb' do |csv|
    csv << HEADERS
    CSV.foreach DB_FILE, :headers => :first_row do |row|
      retry_count = 0
      print "Mapping #{row['Name']} at #{postcode}..."
      begin
        if row['MapIt ID'].to_s.strip == ""
	  postcode = row['Address'].split(/\n/)[-1]
	  local_authority = MySociety::MapIt::Postcode.new(postcode).local_authority
          print ' '
	  if local_authority.nil?
            #sleep 30
            raise "Failed to locate authority record for #{row['Name']} at #{postcode}"
	  else
	    row['MapIt ID'] = "http://mapit.mysociety.org/area/#{local_authority.id}"
	    puts row['MapIt ID']
	  end
        end
      rescue => e
        retry_count += 1
        if retry_count < 5
          print '.'
          retry
        else
          puts e.message
          puts row.fields.inspect
        end
      end
      csv << row.fields
    end
  end
  FileUtils.mv TMP_FILE, DB_FILE
end

task :generate => [ :local_authorities, :map_it ]
