require "iso9660/version"
require "iso9660/directories"

require "iso9660/volume_descriptors/boot"
require "iso9660/volume_descriptors/primary_volume_descriptor"
require "iso9660/volume_descriptors/supplementary_volume_descriptor"
require "iso9660/volume_descriptors/volume_partition"
require "iso9660/volume_descriptors/terminator"

require "iso9660/byte_order_helpers"


class Iso
  include VolumeDescriptor
  include ByteOrderHelpers  
  include Directories
  # 32 byte system data size
  SYSTEM_DATA = 0x8000

  attr_reader :stream
  attr_writer :logical_block_size
  attr_writer :endianness
  attr_reader :files

  attr_accessor :boot
  attr_accessor :primary_volume_descriptor
  attr_accessor :supplementary
  attr_accessor :partition
  attr_accessor :terminator

  # Automatically reads file if stream is set
  #
  # * *Args*    :
  #   - +stream+ -> Open file stream
  # * *Raises* :
  #   - +Error+ -> if system endianness cannot be determined
  def initialize(stream = nil)
    @endianness ||= ByteOrderHelpers::endianness

    if !stream.nil?
      @logical_block_size ||= 2048
      @stream = stream

      read
    end
  end

  # Read stream stream
  def read
    # Start after the 32KB Unused System Data area
    @stream.pos = SYSTEM_DATA
    
    @files = {}
    @terminator = nil

    while (!@stream.eof? && @terminator.nil?)
      start_pos = @stream.pos
      buffer = @stream.read(@logical_block_size)
      type, identifier = buffer.unpack("CA5")

      if identifier == "CD001"

        case type
        when BOOT_RECORD
          @boot = Boot.new(buffer,start_pos,stream.pos-1)
        when PRIMARY_VOLUME_DESCRIPTOR
          @primary_volume_descriptor = PrimaryVolumeDescriptor.new(buffer,start_pos,stream.pos-1)
          @logical_block_size = @primary_volume_descriptor.logical_block_size
        when SUPPLEMENTARY_VOLUME_DESCRIPTOR
          #TODO incomplete
          @supplementary = SupplementaryVolumeDescriptor.new(buffer,start_pos,stream.pos-1)
        when VOLUME_PARTITION
          #TODO incomplete
          @partition = VolumePartition.new(buffer,start_pos,stream.pos-1)
        when TERMINATOR
          @terminator = Terminator.new(buffer,start_pos,stream.pos-1)
        end
      end
    end
    
    path_table
  end
  
  def path_table
    @stream.pos = if @endianness == :little
                    @primary_volume_descriptor.path_table_l_loc * @logical_block_size
                  else
                    @primary_volume_descriptor.path_table_m_loc * @logical_block_size
                  end
                  
    buffer = stream.read(@primary_volume_descriptor.path_table_size)
    while buffer.length > 0
      path = {}
      desc_length = buffer[0].unpack_unsigned_char
      #path[:Extended_Attribute_length] = buffer[offset+1, 2].unpack_little_uint32
      lba = buffer[2, 4].unpack_little_uint32
      path[:parent_directory_index] = buffer[6, 2].unpack_native_uint16
      path[:name] = buffer[8, desc_length].unpack_binary_string

      @files[lba] = path
      
      #find files
      @stream.pos = lba * @logical_block_size
      @files[lba][:files] = parse_sector(@stream.read(@logical_block_size))
      
      # +1 Length of Directory Identifier
      # +1 Extended Attribute Record Length 
      # +4 Location of Extent (LBA)
      # +2 Directory number of parent directory
      # +X Length of description
      # +1 only if the length of the description is odd
      buffer = buffer[8 + desc_length + (desc_length % 2)..-1]
    end
  end

  # stream dump if stream set
  #
  # * *Args*    :
  #   - +stream+ -> Open file stream
  def dump(stream = nil)
    # TODO fill me in
  end

end