require "iso9660/byte_order_helpers"

class Iso
  class Directories
    include ByteOrderHelpers
    
    attr_reader :files
    
    FLAGS = {
        0 => :hidden,
        1 => :directory,
        2 => :associated_file,
        3 => :extended_attribute_format_information,
        4 =>:extended_attribute_permissions,
        7 => :not_final_entry
      }
  
    def initialize
      @files = []
    end
    
    def parse_sector(buffer)
      file = {}
      
      # Length of Directory Record.
      record_length = buffer[0].unpack_unsigned_char

      if record_length == 0
        @files[0] = nil
      end
      
      file[:Extended_Attribute_length] = buffer[1].unpack_unsigned_char
      file[:lba] = buffer[2, 4].unpack_little_uint32
      file[:ex_location] = buffer[10, 4].unpack_little_uint32
      file[:ex_size] = buffer[14, 4].unpack_little_uint32
      file[:write_datatime] = buffer[18, 7].unpack_little_uint32
 
      file[:file_attribute] = FLAGS[buffer[25].unpack_unsigned_char]
      file[:interleaved_unit_size] = buffer[26].unpack_unsigned_char
      file[:interleaved_gap_size] = buffer[27].unpack_unsigned_char
      file[:volume_sequence_number] = buffer[28, 4].unpack_native_uint16
      file_name_length = buffer[32].unpack_unsigned_char 

      file[:file_name] = buffer[33, file_name_length].unpack_binary_string
      
      system_use_start = 34 + file_name_length - (file_name_length % 2)
      system_use_length = (record_length - system_use_start > 255) ? 255 : (record_length - system_use_start )

      file[:system_use] = buffer[system_use_start, system_use_length]
      
      @files.push(file)
    end
  end
end