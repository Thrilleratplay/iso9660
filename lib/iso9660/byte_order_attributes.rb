require "virtus"

class Iso
  class ::String
    def dehex(directive)
      if directive == "A"
      directive += self.length.to_s
      end
      self.unpack(directive).each{|x| return x.nil? ? self : x}
    end
  end

  class EndianInteger < Virtus::Attribute
    def coerce(value)
      if (value.is_a?(::String) && !value[/^\\x\h\h/])
        case value.length
        when 1
          # Unsigned 8-bit integer
          value.dehex("C")
        when 4
          # Native-endian encoded unsigned 16-bit integer.
          value.dehex("S")
        when 8
          # Native-endian encoded unsigned 32-bit integer.
          value.dehex("L")
        else
        raise("what the hell is this crap?",value)
        end
      else
      value
      end
    end
  end

  class BigEndianInteger < Virtus::Attribute
    def coerce(value)
      if (value.is_a?(::String) && !value[/^\\x\h\h/] && value.length == 4)
        # Big-endian encoded unsigned 32-bit integer.
        value.dehex("N")
      else
        raise("uh oh, not big endian",value)
      end
    end
  end

  class LittleEndianInteger < Virtus::Attribute
    def coerce(value)
      if (value.is_a?(::String) && !value[/^\\x\h\h/] && value.length == 4)
        # Little-endian encoded unsigned 32-bit integer.
        value.dehex("V")
      else
        puts !value[/^\\x\h\h/]
        puts value.inspect
        raise("uh oh, not little endian",value)
      end
    end
  end

  class EndianString < Virtus::Attribute
    def coerce(value)
      if (value.length == 1 && !value[/^\\x\h\h/])
        value.dehex("C")
      elsif !value[/^\\x\h\h/]
        value.dehex("A")
      else
        value
      end
    end
  end


  module Endianness
    class << self
      attr_writer :endian
      def endian
        @endian ||= native_endian
      end

      private

      # Determine system endianness
      #
      # * *Returns* :
      # - :big or :little
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
end
