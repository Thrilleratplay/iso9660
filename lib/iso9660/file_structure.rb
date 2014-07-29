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
    property :location_of_extent
    property :parent_directory_index
    property :name
    property :files, default: []
    property :subdirectories, default: []
  end 
    
  class FileMetadata < Hashie::Dash
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
    
    def initialize
      @directories = []
    end
    
    def parse_path_table(stream, path_table_loc, path_table_size, logical_block_size = 2048)
      stream.pos = path_table_loc * logical_block_size
      
      path_buffer = stream.read(path_table_size)
      while path_buffer.length > 0
        path = DirectoryMetadata.new
        
        desc_length = path_buffer[0].unpack_unsigned_char
        #path[:Extended_Attribute_length] = buffer[offset+1, 2].unpack_little_uint32
        path.location_of_extent = path_buffer[2, 4].unpack_little_uint32
        path.parent_directory_index = path_buffer[6, 2].unpack_native_uint16
        path.name = path_buffer[8, desc_length].unpack_binary_string

        #find files
        stream.pos = path.location_of_extent * logical_block_size
        path.files = parse_directory_sector(stream.read(logical_block_size))
      
        @directories.push(path)
      
        # +1 Length of Directory Identifier
        # +1 Extended Attribute Record Length 
        # +4 Location of Extent (LBA)
        # +2 Directory number of parent directory
        # +X Length of description
        # +1 only if the length of the description is odd
        path_buffer = path_buffer[8 + desc_length + (desc_length % 2)..-1]
      end
    end      

    
    def parse_directory_sector(buffer)
      files = []
      

      while buffer.length > 0
        # Length of Directory Record.
        record_length = buffer[0].unpack_unsigned_char

        if record_length == 0
          buffer = buffer[1..-1]
        else
          file = FileMetadata.new 
          #extended_Attribute_length = buffer[1].unpack_unsigned_char
          lba = buffer[2, 8].unpack_native_uint32
          
          file.size_of_extent = buffer[10, 8].unpack_native_uint32
          file.recording_datetime = buffer[18, 7].unpack_little_uint32

          file.file_attribute = FILE_FLAGS[buffer[25].unpack_unsigned_char]
          file.interleaved_unit_size = buffer[26].unpack_unsigned_char
          file.interleaved_gap_size = buffer[27].unpack_unsigned_char
          file.volume_sequence_number = buffer[28, 4].unpack_native_uint16

          file_name_length = buffer[32].unpack_unsigned_char

          file.name = buffer[33, file_name_length].unpack_binary_string.split(';').first

          system_use_start = 34 + file_name_length - (file_name_length % 2)
          system_use_length = (record_length - system_use_start > 255) ? 255 : (record_length - system_use_start )

          file.system_use = buffer[system_use_start, system_use_length]
          if (file.name != "\x01" && !file.name.nil?)
            files.push(file)
          end
          buffer = buffer[record_length..-1]
        end
      end
      
      files
    end
  end
end