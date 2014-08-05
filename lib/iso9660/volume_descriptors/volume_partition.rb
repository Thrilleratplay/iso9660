class Iso
  module VolumeDescriptor
    VOLUME_PARTITION = 0x03
    class VolumePartition
      include Virtus.model

      attribute :start_pos, Integer, :allow_nil => true
      attribute :end_pos, Integer, :allow_nil => true
      attribute :type, EndianInteger, :default => VOLUME_PARTITION
      def initialize(buf, start_pos, end_pos)
        self.start_pos = start_pos
        self.end_pos = end_pos
      end
    end
  end
end