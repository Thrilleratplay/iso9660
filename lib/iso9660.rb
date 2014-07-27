require "iso9660/version"
require "iso9660/directories"

require "iso9660/volume_descriptors/boot"
require "iso9660/volume_descriptors/primary_volume_descriptor"
require "iso9660/volume_descriptors/supplementary_volume_descriptor"
require "iso9660/volume_descriptors/volume_partition"
require "iso9660/volume_descriptors/terminator"

class Iso
  include VolumeDescriptor
  # 32 byte system data size
  SYSTEM_DATA = 0x8000

  attr_reader :stream
  attr_writer :logical_block_size
  attr_writer :endianness

  attr_accessor :boot
  attr_accessor :primary_volume_descriptor
  attr_accessor :supplementary
  attr_accessor :partition
  attr_accessor :terminator

  # Automatically reads file if stream is set
  #
  # * *Args*    :
  #   - +stream+ -> Open file stream
  #   - +offset+ -> Byte offset
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
        when SUPPLEMENTARY_VOLUME_DESCRIPTOR
          #TODO
          @supplementary = SupplementaryVolumeDescriptor.new(buffer,start_pos,stream.pos-1)
        when VOLUME_PARTITION
          #TODO
          @partition = VolumePartition.new(buffer,start_pos,stream.pos-1)
        when TERMINATOR
          @terminator = Terminator.new(buffer,start_pos,stream.pos-1)
        end
      end
    end
=begin
  @logical_block_size = @volume_descriptor.primary.data.logical_block_size

  path_table_loc = if @endianness == :little
  @volume_descriptor.primary.data.path_table_l_loc
  else
  @volume_descriptor.primary.data.path_table_m_loc
  end

  @path_table = PathTable.new(@stream,path_table_loc ,@logical_block_size, @volume_descriptor.primary.data.path_table_size)
  @directories = Directories.new

  @path_table.paths.each{ |f|
  stream.pos = f[:lba] * @logical_block_size
  directories.parse_sector(stream.read(@logical_block_size))
  }
=end
  end

  # stream dump if stream set
  #
  # * *Args*    :
  #   - +stream+ -> Open file stream
  #   - +offset+ -> Byte offset
  def dump(stream = nil, offset = Offset.THIRTY_TWO_BYTES)
    # TODO fill me in
  end

end