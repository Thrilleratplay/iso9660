require "tmpdir"
require "fileutils"
require "virtus"
require "iso9660/byte_order_attributes"
#require "iso9660/extensions/rrip"

class Iso
    FILE_FLAGS = {
      "\x01" => :hidden,
      "\x02" => :directory,
      "\x04" => :associated_file,
      "\x08" => :extended_attribute_format_information,
      "\x10" => :extended_attribute_permissions,
      "\x100" => :not_final_entry
    }

  class DirectoryMetadata
    include Virtus.model
    attribute :start_pos, Integer,:min => 0, :allow_nil => true
    attribute :length_in_bytes, EndianInteger, :min => 0
    attribute :parent_directory_index
    attribute :name, EndianString, :default => ""
    attribute :files, Array ,:default => []
    attribute :subdirectories, Array, :default => []
  end

  class FileMetadata
    include Virtus.model
    attribute :start_pos, Integer,:min => 0, :allow_nil => true
    attribute :length_in_bytes, EndianInteger, :min => 0

    #attribute :extended_attribute_length
    #attribute :interleaved_unit_size, default: 0 # offset: 26, size:1
    #attribute :interleaved_gap_size, default: 0  # offset: 27, size:1

    attribute :timestamp, DateTime                # offset: 18, size:7
    attribute :file_attribute                    # offset: 25, size:1
    attribute :vol_sequence_number               # offset: 28, size:4
    attribute :name                              # offset: 33, size:variable
    attribute :system_use
    attribute :rock_ridge
  end
=begin
  class DirectoryStructure
    include Virtus.model
    attribute :id, Integer,:default => 0, :min => 0
    attribute :parent_id,  Integer, :default => nil, :allow_nil => true
    attribute :files, Array[FileMetadata]
    attribute :subdirectories, []
  end
=end
  class FileStructure
    #include RRIP
    attr_accessor :directories
    attr_reader :block_size

    def initialize(stream = nil, pt_loc = 0, pt_size = 0, block_size = 2048)
      @directories = []
      @block_size = block_size

      if !stream.nil?
        self.parse_path_table(stream, pt_loc, pt_size)
      end
    end

    def parse_path_table(stream, pt_loc, pt_size)
      stream.pos = pt_loc * block_size

      pbuf = stream.read(pt_size)
      while pbuf.length > 0
        path = DirectoryMetadata.new
        #path.extended_attribute_length = pbuf[1, 2].unpack_uint16
        #path.location_of_extent = pbuf[2, 4]
        path.parent_directory_index = pbuf[6, 2]

        desc_len = pbuf[0].dehex("C")
        path.name = pbuf[8, desc_len]

        #find files
        stream.pos = pbuf[2, 4].dehex("S") * @block_size
        path.files, path.subdirectories = parse_directory_sector(stream.read(@block_size))

        @directories.push(path)

        # +1 Length of Directory Identifier
        # +1 Extended Attribute Record Length
        # +4 Location of Extent (LBA)
        # +2 Directory number of parent directory
        # +X Length of description
        # +1 only if the length of the description is odd
        pbuf = pbuf[8 + desc_len + (desc_len % 2)..-1]
      end
    end


    def parse_directory_sector(fbuf)
      files = []
      subdirectories = []

      while fbuf.length > 0
        # Length of Directory Record.
        record_len= fbuf[0].dehex("C")

        if record_len == 0
          fbuf = fbuf[1..-1]
        else
          file = FileMetadata.new
          #file.extended_attribute_length = fbuf[1].unpack_char
          file.start_pos = fbuf[2, 8].dehex("L") * @block_size
          file.length_in_bytes = fbuf[10, 8].dehex("L") * @block_size

          # TODO need a method to translate this in
          #file.recording_datetime = fbuf[18, 7]

          file.file_attribute = FILE_FLAGS[fbuf[25]]
          # file.interleaved_unit_size = fbuf[26].unpack_char
          # file.interleaved_gap_size = fbuf[27].unpack_char
          file.vol_sequence_number = fbuf[28, 4]

          file_name_length = fbuf[32].dehex("C")

          file.name = fbuf[33, file_name_length].dehex("A").split(';').first

          system_use_start = 34 + file_name_length - (file_name_length % 2)
          system_use_len = record_len - system_use_start

          file.system_use = fbuf[system_use_start, system_use_len]
          #file.rock_ridge = RockRidge.new(file.system_use)

          # Exclude "." and ".." from directory listings
          if file.file_attribute != :directory
            file.name.sub!(/\.$/, '')
            files.push(file)
          elsif(file.name != "\x01" && !file.name.nil?)
            subdirectories.push(file)
          end
          fbuf = fbuf[record_len..-1]
        end
      end

      [files,subdirectories]
    end

    def extract_all(root_dir, stream, block_size)
      # TODO rewrite recursive
      tmpdir = root_dir | Dir.mktmpdir
      tmpdir = "./tmp"
      @directories.each{ |dir|
        FileUtils.mkdir_p "#{tmpdir}#{dir.full_path}"
        dir.files.each{|file|
          stream.pos = file.location_of_extent * block_size
          if !File.exist?("#{tmpdir}#{dir.full_path}/#{file.name}")
            IO.binwrite("#{tmpdir}#{dir.full_path}/#{file.name}", stream.read(file.size_of_extent))
          end
        }
      }
    end
  end
end
