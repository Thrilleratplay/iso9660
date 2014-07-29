require "hashie"

class Iso
  module VolumeDescriptor
    SUPPLEMENTARY_VOLUME_DESCRIPTOR = 0x02
    class SupplementaryVolumeDescriptor < Hashie::Dash
      property :start_pos
      property :end_pos
      property :type, default: SUPPLEMENTARY_VOLUME_DESCRIPTOR
      def initialize(buff = "", start_pos, end_pos)
        self.start_pos = start_pos
        self.end_pos = end_pos
        self.type = buff[0].unpack_char
      end
    end
  end
end  