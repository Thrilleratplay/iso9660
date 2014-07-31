require "spec_helper"
require 'iso9660'

describe Iso9660 do
  #TODO create special test ISO and proper test
  it "check boot system identifier" do
    stream = File.open(File.dirname(__FILE__)  + '/boot2docker.iso', "rb+")
    iso = Iso.new(stream)
    expect(iso.boot.boot_system_identifier).to eq("EL TORITO SPECIFICATION")
    
    iso.file_struct.directories.each{|x| 
      #puts x.name,x.parent_directory_index
      x.files.each{|y| puts "#{y}"}
      }
  end
end