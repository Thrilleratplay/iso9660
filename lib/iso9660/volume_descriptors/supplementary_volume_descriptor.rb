class Iso
  module VolumeDescriptor
    SUPPLEMENTARY_VOLUME_DESCRIPTOR = 0x02
    class SupplementaryVolumeDescriptor
      include Virtus.model

      attribute :start_pos, Integer, :allow_nil => true
      attribute :end_pos, Integer, :allow_nil => true
      attribute :type, EndianInteger, :default => SUPPLEMENTARY_VOLUME_DESCRIPTOR
      def initialize(buf, start_pos, end_pos)
        self.start_pos = start_pos
        self.end_pos = end_pos
      end
    end
  end
end