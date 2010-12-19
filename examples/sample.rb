require '../binary_parser.rb'

include BinaryProcessor

# Define IP type according to RFC. It will register according to the first parameter,
# which is currently the :IP.
Packet.type :IP do |ip|
  
  # You can use 4.bits to read 4 bits
  ip.version          4.bits, :unsigned
  ip.header_length    4.bits, :unsigned

  # You can define options for a value, for instance the Type of Service can be the following:
  ip.type_of_service  1.byte do |value|
    value[0x000] = "Routine"
    value[0x001] = "Priority"
    value[0x010] = "Immediate"
    value[0x011] = "Flash"
    value[0x100] = "Flash Override"
    value[0x101] = "CRITIC/ECP"
    value[0x110] = "Internet Control"
    value[0x111] = "Network Control"
  end
  
  # You can display its value in decimal form
  ip.total_length_of_whole_datagram 2.bytes, :decimal
  ip.identification 2.bytes

  # Use :flags when the value is composition of different options
  ip.flags 3.bits, :flags do |flag|
    flag[0x1] = "More"
    flag[0x2] = "Don't fragment"
    flag[0x4] = "More fragment"
  end
  ip.fragment_offset  13.bits
  ip.time_to_live     1.byte
  ip.protocol         1.byte, :decimal
  ip.header_checksum  2.bytes, :binary
  ip.source_address   4.bytes, :decimal
  ip.target_address   4.bytes, :decimal

  # You can use the parsed information using ? sign after its name
  if ip.header_length? > 5
    ip.copied_flag  1.bit {|v| v = {0x0 => "Not copied", 0x1 => "Copied"}}
    ip.option_class 2.bits {|v| v = {0x0 => "control", 0x02 => "debugging measurement"}}
    ip.option_class 5.bits
  end

end

# Define a packet in array form (currently this is the only supported solution)
packet = [0x45, 0x00, 0x05, 0xd4, 0x73, 0x67, 0x40, 0x00, 0x39, 0x06, 0x48, 0x94, 0x58, 0x97, 0x65, 0xe7,
          0xc0, 0xa8, 0x01, 0x02, 0x03, 0xe1, 0xdf, 0x78, 0xf1, 0x08, 0xa7, 0x6e, 0xd6, 0x89, 0x92, 0x85]

# Process the packet as an :IP
Packet.process packet, [:IP]