module ByteOrderHelpers
  class ::String
    # 8-bit unsigned (unsigned char)
    #
    # * *Args*    :
    #   - +self+ -> String
    # * *Returns* :
    #   - unpacked integer or nil 
    def unpack_char
      self.unpack("C").first ||= nil
    end

    # 16-bit unsigned, native endian (uint16_t)
    #
    # * *Args*    :
    #   - +self+ -> String
    # * *Returns* :
    #   - unpacked integer or nil     
    def unpack_uint16
      self.unpack("S").first ||= nil
    end

    # 32-bit unsigned, native endian (uint32_t)
    #
    # * *Args*    :
    #   - +self+ -> String
    # * *Returns* :
    #   - unpacked integer or nil     
    def unpack_uint32
      self.unpack("L").first ||= nil
    end

    # 32-bit unsigned, network (big-endian) byte order
    #
    # * *Args*    :
    #   - +self+ -> String
    # * *Returns* :
    #   - unpacked integer or nil     
    def unpack_uint32be
      self.unpack("N").first ||= nil
    end

    # 32-bit unsigned, VAX (little-endian) byte order
    #
    # * *Args*    :
    #   - +self+ -> String
    # * *Returns* :
    #   - unpacked integer or nil     
    def unpack_uint32le
      self.unpack("V").first ||= nil
    end

    # arbitrary binary string (remove trailing nulls and ASCII spaces)
    #
    # * *Args*    :
    #   - +self+ -> String
    # * *Returns* :
    #   - unpacked integer or nil     
    def unpack_string
      self.unpack("A#{self.length}").first ||= nil
    end
  end
  
  class << self
    attr_writer :endian
    
    def endian
      @endian ||= native_endian
    end
    
    private
    # Determine system endianness
    #
    # * *Returns* :
    #   - :big or :little     
    def native_endian
      if "\0\1".unpack("s").first == 1
        :big
      elsif "\0\1".unpack("s").first == 256
        :little
      else
        raise("Cannot determine endianness")
      end
    end
  end
end