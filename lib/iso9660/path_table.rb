require "iso9660/byte_order_helpers"

class Iso
  class PathTable
    include ByteOrderHelpers
        
    attr_reader :start_pos
    attr_reader :end_pos    
    attr_reader :path_table_size
    attr_reader :logical_block_size
    attr_reader :paths
  
    def initialize(stream = nil, path_table_loc = 0, logical_block_size = 0, path_table_size = 0)
      @path_table_size ||= path_table_size
      @logical_block_size ||= logical_block_size 
      @start_pos ||= path_table_loc * logical_block_size 
      @end_pos ||= @start_pos + @path_table_size
      @paths = []
      
      stream.pos = start_pos
      if (!stream.nil? && @end_pos > 0)
        parse_path_table(stream.read(@path_table_size))
      end
    end 
    
    def parse_path_table(buffer)  
      offset = 0
      while offset < buffer.length
        path ={}
        desc_length = buffer[offset].unpack_unsigned_char
        #path[:Extended_Attribute_length] = buffer[offset+1, 2].unpack_little_uint32
        path[:lba] = buffer[offset+2, 4].unpack_little_uint32
        path[:parent_directory_index] = buffer[offset+6, 2].unpack_native_uint16
        path[:name] = buffer[offset+8, desc_length].unpack_binary_string

        @paths.push(path)
        
        # Offset is the length of the description plus 
        # +1 Length of Directory Identifier
        # +1 Extended Attribute Record Length 
        # +4 Location of Extent (LBA)
        # +2 Directory number of parent directory
        # +X Length of description
        # +1 only if the length of the description is odd
        offset += 8 + desc_length + (desc_length % 2)
      end
    end
  end 
end
