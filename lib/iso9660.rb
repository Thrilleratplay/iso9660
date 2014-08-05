require "iso9660/version"
require "iso9660/file_structure"

require "iso9660/byte_order_attributes"

require "iso9660/volume_descriptors/boot"
require "iso9660/volume_descriptors/primary_volume_descriptor"
require "iso9660/volume_descriptors/supplementary_volume_descriptor"
require "iso9660/volume_descriptors/volume_partition"
require "iso9660/volume_descriptors/terminator"

class Iso
  include VolumeDescriptor
  include Endianness
  # 32 byte system data size
  SYSTEM_DATA = 0x8000

  attr_reader :stream
  attr_writer :logical_block_size
  attr_writer :endian
  attr_reader :file_struct

  attr_accessor :boot
  attr_accessor :pvd # Primary Volume Descriptor
  attr_accessor :svd # Supplementary Volume Descriptor
  attr_accessor :partition
  attr_accessor :terminator

  # Automatically reads file if stream is set
  #
  # * *Args*    :
  #   - +stream+ -> Open file stream
  # * *Raises* :
  #   - +Error+ -> if system endianness cannot be determined
  def initialize(stream = nil)
    @endian ||= Endianness::endian

    if !stream.nil?
      @block_size ||= 2048
      @stream = stream
      read
    end
  end

  # Read stream stream
  def read
    # Start after the 32KB Unused System Data area
    @stream.pos = SYSTEM_DATA

    #@file_struct = FileStructure.new
    @terminator = nil

    while (!@stream.eof? && @terminator.nil?)
      start_pos = @stream.pos
      buf = @stream.read(@block_size)
      type, identifier = buf.unpack("CA5")

      if identifier == "CD001"
        case type
        when BOOT_RECORD
          @boot = Boot.new(buf,start_pos,stream.pos-1)
        when PRIMARY_VOLUME_DESCRIPTOR
          @pvd = PrimaryVolumeDescriptor.new(buf,start_pos,stream.pos-1)
          @block_size = @pvd.block_size
        when SUPPLEMENTARY_VOLUME_DESCRIPTOR
          #TODO incomplete
          @svd = SupplementaryVolumeDescriptor.new(buf,start_pos,stream.pos-1)
        when VOLUME_PARTITION
          #TODO incomplete
          @partition = VolumePartition.new(buf,start_pos,stream.pos-1)
        when TERMINATOR
          @terminator = Terminator.new(buf,start_pos,stream.pos-1)
        end
      end
    end

    path_table_loc = if @endian == :little
                       @pvd.path_table_l_loc
                     else
                       @pvd.path_table_m_loc
                     end
    @file_struct=FileStructure.new(@stream, path_table_loc, @pvd.path_table_size, @block_size)
   # @file_struct.extract_all(@stream, @block_size)
  end


  # stream dump if stream set
  #
  # * *Args*    :
  #   - +stream+ -> Open file stream
  def dump(stream = nil)
    # TODO fill me in
  end

end