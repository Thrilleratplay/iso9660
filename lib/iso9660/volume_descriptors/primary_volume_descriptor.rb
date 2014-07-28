require "iso9660/byte_order_helpers"

class Iso
  module VolumeDescriptor
    include ByteOrderHelpers

    PRIMARY_VOLUME_DESCRIPTOR = 0x01
    class PrimaryVolumeDescriptor
      attr_writer :start_pos
      attr_writer :end_pos
      attr_writer :type
      attr_writer :system_identifier
      attr_writer :volume_identifier
      attr_writer :volume_space_size
      attr_writer :volume_set_size
      attr_writer :volume_seq_num
      attr_writer :logical_block_size
      attr_writer :path_table_size
      attr_writer :path_table_l_loc
      attr_writer :path_table_opt_l_loc
      attr_writer :path_table_m_loc
      attr_writer :path_table_opt_m_loc
      attr_writer :volume_set_identifer
      attr_writer :publisher_identifier
      attr_writer :data_preparer_identifier
      attr_writer :application_identifier
      attr_writer :copyright_file_identifier
      attr_writer :abstract_file_identifier
      attr_writer :bibliographic_file_identifier
      attr_writer :volume_datetime_created
      attr_writer :volume_datetime_modified
      attr_writer :volume_datetime_expires
      attr_writer :volume_datetime_effective
      attr_writer :file_structure_version
      attr_writer :application_used
      def start_pos
        @start_pos ||= nil
      end

      def end_pos
        @end_pos ||= nil
      end

      def type
        @type ||= PRIMARY_VOLUME_DESCRIPTOR
      end

      def system_identifier
        @system_identifier = nil
      end

      def volume_identifier
        @volume_identifier ||= ""
      end

      def volume_space_size
        @volume_space_size ||= nil
      end

      def volume_set_size
        @volume_set_size ||= nil
      end

      def volume_seq_num
        @volume_seq_num ||= nil
      end

      def logical_block_size
        @logical_block_size ||= nil
      end

      def path_table_size
        @path_table_size ||= nil
      end

      def path_table_l_loc
        @path_table_l_loc ||= nil
      end

      def path_table_opt_l_loc
        @path_table_opt_l_loc ||= nil
      end

      def path_table_m_loc
        @path_table_m_loc ||= nil
      end

      def path_table_opt_m_loc
        @path_table_opt_m_loc ||= nil
      end

      def volume_set_identifer
        @volume_set_identifer ||= ""
      end

      def publisher_identifier
        @publisher_identifier ||= 0x20
      end

      def data_preparer_identifier
        @data_preparer_identifier ||= 0x20
      end

      def application_identifier
        @application_identifier ||= 0x20
      end

      def copyright_file_identifier
        @copyright_file_identifier ||= 0x20
      end

      def abstract_file_identifier
        @abstract_file_identifier ||= 0x20
      end

      def bibliographic_file_identifier
        @bibliographic_file_identifier ||= 0x20
      end

      def volume_datetime_created
        @volume_datetime_created ||= nil
      end

      def volume_datetime_modified
        @volume_datetime_modified ||= nil
      end

      def volume_datetime_expires
        @volume_datetime_expires ||= nil
      end

      def volume_datetime_effective
        @volume_datetime_effective ||= nil
      end

      def file_structure_version
        @file_structure_version ||= nil
      end

      def application_used
        @application_used ||= nil
      end
      
      def initialize(buffer = "", start_pos = nil, end_pos = nil)
        @start_pos = start_pos
        @end_pos = end_pos
        @type = buffer[0].unpack_unsigned_char
        @system_identifier = buffer[8, 32].unpack_binary_string
        @volume_identifier = buffer[40, 32].unpack_binary_string
        @volume_space_size = buffer[80, 8].unpack_native_uint32
        @volume_set_size = buffer[120, 4].unpack_native_uint16
        @volume_seq_num = buffer[124, 4].unpack_native_uint16
        @logical_block_size = buffer[128, 4].unpack_native_uint16
        @path_table_size = buffer[132, 8].unpack_native_uint32
        @path_table_l_loc = buffer[140, 4].unpack_little_uint32
        @path_table_opt_l_loc = buffer[144, 4].unpack_little_uint32
        @path_table_m_loc = buffer[148, 4].unpack_big_uint32
        @path_table_opt_m_loc = buffer[152, 4].unpack_big_uint32
        #Record.parse(buffer[156, 34])
        @volume_set_identifer = buffer[190, 128].unpack_binary_string
        @publisher_identifier = buffer[318, 128].unpack_binary_string
        @data_preparer_identifier = buffer[446, 128].unpack_binary_string
        @application_identifier = buffer[574, 128].unpack_binary_string
        @copyright_file_identifier = buffer[702, 38].unpack_binary_string
        @abstract_file_identifier = buffer[740, 36].unpack_binary_string
        @bibliographic_file_identifier = buffer[776, 37].unpack_binary_string
        @volume_datetime_created = buffer[813, 17].unpack_binary_string
        @volume_datetime_modified = buffer[830, 17].unpack_binary_string
        @volume_datetime_expires = buffer[847, 17].unpack_binary_string
        @volume_datetime_effective = buffer[864, 17].unpack_binary_string
        @file_structure_version = buffer[881].unpack_unsigned_char
        @application_used = buffer[883, 512].unpack_binary_string
      end
    end
  end
end