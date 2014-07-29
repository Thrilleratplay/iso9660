require "iso9660/version"
require "iso9660/file_structure"

require "iso9660/volume_descriptors/boot"
require "iso9660/volume_descriptors/primary_volume_descriptor"
require "iso9660/volume_descriptors/supplementary_volume_descriptor"
require "iso9660/volume_descriptors/volume_partition"
require "iso9660/volume_descriptors/terminator"

require "iso9660/byte_order_helpers"


class Iso
  include VolumeDescriptor
  include ByteOrderHelpers 
  # 32 byte system data size
  SYSTEM_DATA = 0x8000

  attr_reader :stream
  attr_writer :logical_block_size
  attr_writer :endianness
  attr_reader :file_struct

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
    
    @file_struct = FileStructure.new
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
    
    scan_directories
  end
  
  def scan_directories
    path_table_loc = if @endianness == :little
                       @primary_volume_descriptor.path_table_l_loc 
                     else
                       @primary_volume_descriptor.path_table_m_loc
                     end
             
  
    @file_struct.parse_path_table(@stream, path_table_loc, @primary_volume_descriptor.path_table_size, @logical_block_size)
  end

  # stream dump if stream set
  #
  # * *Args*    :
  #   - +stream+ -> Open file stream
  def dump(stream = nil)
    # TODO fill me in
  end

end