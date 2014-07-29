require "hashie"
require "iso9660/byte_order_helpers"

class Iso
    FILE_FLAGS = {
      0 => :hidden,
      1 => :directory,
      2 => :associated_file,
      3 => :extended_attribute_format_information,
      4 => :extended_attribute_permissions,
      7 => :not_final_entry
    }
   
  class DirectoryMetadata < Hashie::Dash
    property :extended_attribute_length
    property :location_of_extent
    property :parent_directory_index
    property :name
    property :files, default: []
    property :subdirectories, default: []
  end 
    
  class FileMetadata < Hashie::Dash
    property :extended_attribute_length    
    property :location_of_extent                # offset: 2, size:8
    property :size_of_extent                    # offset: 10, size:8
    property :recording_datetime                # offset: 18, size:7
    property :file_attribute                    # offset: 25, size:1
    property :interleaved_unit_size, default: 0 # offset: 26, size:1
    property :interleaved_gap_size, default: 0  # offset: 27, size:1
    property :volume_sequence_number            # offset: 28, size:4
    property :name                              # offset: 33, size:variable
    property :system_use
  end
  
  class FileStructure
    attr_accessor :directories
    
    def initialize(stream = nil, pt_loc = 0, pt_size = 0, block_size = 2048)
      @directories = []
      
      if !stream.nil?
        self.parse_path_table(stream, pt_loc, pt_size, block_size)
      end
    end
    
    def parse_path_table(stream, pt_loc, pt_size, block_size)
      stream.pos = pt_loc * block_size
      
      pbuf = stream.read(pt_size)
      while pbuf.length > 0
        desc_len = pbuf[0].unpack_char
        
        path = DirectoryMetadata.new
        path.extended_attribute_length = pbuf[1, 2].unpack_uint16
        path.location_of_extent = pbuf[2, 4].unpack_uint32le
        path.parent_directory_index = pbuf[6, 2].unpack_uint16
        path.name = pbuf[8, desc_len].unpack_string

        #find files
        stream.pos = path.location_of_extent * block_size
        path.files = parse_directory_sector(stream.read(block_size))
      
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
      
      while fbuf.length > 0
        # Length of Directory Record.
        record_len= fbuf[0].unpack_char

        if record_len == 0
          fbuf = fbuf[1..-1]
        else
          file = FileMetadata.new 
          file.extended_attribute_length = fbuf[1].unpack_char  
          file.location_of_extent = fbuf[2, 8].unpack_uint32 
          file.size_of_extent = fbuf[10, 8].unpack_uint32
          file.recording_datetime = fbuf[18, 7].unpack_uint32le

          file.file_attribute = FILE_FLAGS[fbuf[25].unpack_char]
          file.interleaved_unit_size = fbuf[26].unpack_char
          file.interleaved_gap_size = fbuf[27].unpack_char
          file.volume_sequence_number = fbuf[28, 4].unpack_uint16

          file_name_length = fbuf[32].unpack_char

          file.name = fbuf[33, file_name_length].unpack_string.split(';').first

          system_use_start = 34 + file_name_length - (file_name_length % 2)
          system_use_len = if (record_len - system_use_start > 255)
                             255
                           else 
                             record_len - system_use_start
                           end
          file.system_use = fbuf[system_use_start, system_use_len]
          
          # Exclude "." and ".." from directory listings
          if (file.name != "\x01" && !file.name.nil?)
            files.push(file)
          end
          fbuf = fbuf[record_len..-1]
        end
      end
      
      files
    end
    
    def extract_all
     # @directories.each{|dir| }
    end
  end
end