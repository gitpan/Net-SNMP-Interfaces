#*****************************************************************************
#*                                                                           *
#*                          Gellyfish Software                               *
#*                                                                           *
#*                                                                           *
#*****************************************************************************
#*                                                                           *
#*      PROGRAM     :  Net::SNMP::Interfaces::Details                        *
#*                                                                           *
#*      AUTHOR      :  JNS                                                   *
#*                                                                           *
#*      DESCRIPTION :  Provide object methods for a particular interface.    *
#*                                                                           *
#*                                                                           *
#*****************************************************************************
#*                                                                           *
#*      $Log: Details.pm,v $
#*      Revision 0.1  2000/11/27 08:36:26  gellyfish
#*
#*                                                                           *
#*                                                                           *
#*****************************************************************************

package Net::SNMP::Interfaces::Details;

use strict;

=head1 NAME

Net::SNMP::Interfaces::Details - Object methods to obtain interface data.

=head1 SYNOPSIS

    $in_octets = $interface->ifInOctets();

=head1 DESCRIPTION

This class represents an individual interface as discovered by
Net::SNMP::Interfaces.  Although it is possible to call the contructor
directly it is primarily intended that these objects should be returned
by methods of Net::SNMP::Interfaces.

=cut

use Net::SNMP;
use Carp;

use vars qw(
            @ISA
            $AUTOLOAD
            $VERSION
           );

($VERSION) = q$Revision: 0.1 $ =~ /([\d.]+)/;

my %OIDS = (
             ifInOctets        => '1.3.6.1.2.1.2.2.1.10',
             ifInUcastPkts     => '1.3.6.1.2.1.2.2.1.11',
             ifInNUcastPkts    => '1.3.6.1.2.1.2.2.1.12',
             ifInDiscards      => '1.3.6.1.2.1.2.2.1.13',
             ifInErrors        => '1.3.6.1.2.1.2.2.1.14',
             ifInUnknownProtos => '1.3.6.1.2.1.2.2.1.15',
             ifOutOctets       => '1.3.6.1.2.1.2.2.1.16',
             ifOutUcastPkts    => '1.3.6.1.2.1.2.2.1.17',
             ifOutNUcastPkts   => '1.3.6.1.2.1.2.2.1.18',
             ifOutDiscards     => '1.3.6.1.2.1.2.2.1.19',
             ifDescr           => '1.3.6.1.2.1.2.2.1.2',
             ifOutErrors       => '1.3.6.1.2.1.2.2.1.20',
             ifOutQLen         => '1.3.6.1.2.1.2.2.1.21',
             ifSpecific        => '1.3.6.1.2.1.2.2.1.22',
             ifType            => '1.3.6.1.2.1.2.2.1.3',
             ifMtu             => '1.3.6.1.2.1.2.2.1.4',
             ifSpeed           => '1.3.6.1.2.1.2.2.1.5',
             ifPhysAddress     => '1.3.6.1.2.1.2.2.1.6',
             ifAdminHack       => '1.3.6.1.2.1.2.2.1.7',  
             ifAdminStatus     => '1.3.6.1.2.1.2.2.1.7',
             ifOperHack        => '1.3.6.1.2.1.2.2.1.8',             
             ifOperStatus      => '1.3.6.1.2.1.2.2.1.8',
             ifLastChange      => '1.3.6.1.2.1.2.2.1.9'
         );

my %IANAifType = (
                  1   => 'other',
                  2   => 'regular1822',
                  3   => 'hdh1822',
                  4   => 'ddnX25',
                  5   => 'rfc877x25',
                  6   => 'ethernetCsmacd',
                  7   => 'iso88023Csmacd',
                  8   => 'iso88024TokenBus',
                  9   => 'iso88025TokenRing',
                  10  => 'iso88026Man',
                  11  => 'starLan',
                  12  => 'proteon10Mbit',
                  13  => 'proteon80Mbit',
                  14  => 'hyperchannel',
                  15  => 'fddi',
                  16  => 'lapb',
                  17  => 'sdlc',
                  18  => 'ds1',
                  19  => 'e1',
                  20  => 'basicISDN',
                  21  => 'primaryISDN',
                  22  => 'propPointToPointSerial',
                  23  => 'ppp',
                  24  => 'softwareLoopback',
                  25  => 'eon',
                  26  => 'ethernet3Mbit',
                  27  => 'nsip',
                  28  => 'slip',
                  29  => 'ultra',
                  30  => 'ds3',
                  31  => 'sip',
                  32  => 'frameRelay',
                  33  => 'rs232',
                  34  => 'para',
                  35  => 'arcnet',
                  36  => 'arcnetPlus',
                  37  => 'atm',
                  38  => 'miox25',
                  39  => 'sonet',
                  40  => 'x25ple',
                  41  => 'iso88022llc',
                  42  => 'localTalk',
                  43  => 'smdsDxi',
                  44  => 'frameRelayService',
                  45  => 'v35',
                  46  => 'hssi',
                  47  => 'hippi',
                  48  => 'modem',
                  49  => 'aal5',
                  50  => 'sonetPath',
                  51  => 'sonetVT',
                  52  => 'smdsIcip',
                  53  => 'propVirtual',
                  54  => 'propMultiplexor',
                  55  => 'ieee80212',
                  56  => 'fibreChannel',
                  57  => 'hippiInterface',
                  58  => 'frameRelayInterconnect',
                  32  => 'frameRelay',
                  44  => 'frameRelayService',
                  59  => 'aflane8023',
                  60  => 'aflane8025',
                  61  => 'cctEmul',
                  62  => 'fastEther',
                  63  => 'isdn',
                  64  => 'v11',
                  65  => 'v36',
                  66  => 'g703at64k',
                  67  => 'g703at2mb',
                  68  => 'qllc',
                  69  => 'fastEtherFX',
                  70  => 'channel',
                  71  => 'ieee80211',
                  72  => 'ibm370parChan',
                  73  => 'escon',
                  74  => 'dlsw',
                  75  => 'isdns',
                  76  => 'isdnu',
                  77  => 'lapd',
                  78  => 'ipSwitch',
                  79  => 'rsrb',
                  80  => 'atmLogical',
                  81  => 'ds0',
                  82  => 'ds0Bundle',
                  83  => 'bsc',
                  84  => 'async',
                  85  => 'cnr',
                  86  => 'iso88025Dtr',
                  87  => 'eplrs',
                  88  => 'arap',
                  89  => 'propCnls',
                  90  => 'hostPad',
                  91  => 'termPad',
                  92  => 'frameRelayMPI',
                  93  => 'x213',
                  94  => 'adsl',
                  95  => 'radsl',
                  96  => 'sdsl',
                  97  => 'vdsl',
                  98  => 'iso88025CRFPInt',
                  99  => 'myrinet',
                  100 => 'voiceEM',
                  101 => 'voiceFXO',
                  102 => 'voiceFXS',
                  103 => 'voiceEncap',
                  104 => 'voiceOverIp',
                  105 => 'atmDxi',
                  106 => 'atmFuni',
                  107 => 'atmIma',
                  108 => 'pppMultilinkBundle',
                  109 => 'ipOverCdlc',
                  110 => 'ipOverClaw',
                  111 => 'stackToStack',
                  112 => 'virtualIpAddress',
                  113 => 'mpc',
                  114 => 'ipOverAtm',
                  115 => 'iso88025Fiber',
                  116 => 'tdlc',
                  117 => 'gigabitEthernet',
                  118 => 'hdlc',
                  119 => 'lapf',
                  120 => 'v37',
                  121 => 'x25mlp',
                  122 => 'x25huntGroup',
                  123 => 'trasnpHdlc',
                  124 => 'interleave',
                  125 => 'fast',
                  126 => 'ip',
                  127 => 'docsCableMaclayer',
                  128 => 'docsCableDownstream',
                  129 => 'docsCableUpstream',
                  130 => 'a12MppSwitch',
                  131 => 'tunnel',
                  132 => 'coffee',
                  133 => 'ces',
                  134 => 'atmSubInterface',
                  135 => 'l2vlan',
                  136 => 'l3ipvlan',
                  137 => 'l3ipxvlan',
                  138 => 'digitalPowerline',
                  139 => 'mediaMailOverIp',
                  140 => 'dtm',
                  141 => 'dcn',
                  142 => 'ipForward',
                  143 => 'msdsl',
                  144 => 'ieee1394',
                  145 => 'if-gsn',
                  146 => 'dvbRccMacLayer',
                  147 => 'dvbRccDownstream',
                  148 => 'dvbRccUpstream',
                  149 => 'atmVirtual',
                  150 => 'mplsTunnel',
                  151 => 'srp',
                  152 => 'voiceOverAtm',
                  153 => 'voiceOverFrameRelay',
                  154 => 'idsl',
                  155 => 'compositeLink',
                  156 => 'ss7SigLink',
                 );
=head2 METHODS

=over

=item new  HASH $args

The constructor for the class.  User code should probably never need to
call the constructor directly as Net::SNMP::Interface::Details objects
are returned by the Net::SNMP::Interfaces methods all_interfaces() and
interface().

There are three mandatory arguments:

=over

=item Session

A valid Net::SNMP object which will be used to make the requests for the
interface information.  This Net::SNMP object should currently only be 
of the blocking variety as no provision has been made for non-blocking
requests at present.

=item Index

The SNMP ifTable index for this interface.

=item Name

The name of this interface (e.g. 'eth0' ).

=back

The Name and Index arguments should have previously been obtained by
SNMP requests to the same host as the Session object has been created for.

=cut

sub new 
{
   my ( $proto, %args ) = @_;

   my $self = {};

   unless ( exists $args{Session} and ref($args{Session}) eq 'Net::SNMP')
   {
     croak "Session must be defined and be a Net::SNMP object";
   }

   $self->{_session} = $args{Session};
   $self->{_index}   = $args{Index};
   $self->{_name}    = $args{Name};

   return bless $self, $proto;
}

=item name

Returns the name of this interace.

=cut

sub name
{
  my ( $self ) = @_;

  return $self->{_name};
}

=item index

Returns the index of this interface.

=cut

sub index
{
  my ( $self ) = @_;

  return $self->{_index};
}

=item session

Returns the Net::SNMP session object that is being used to make requests
for this interface.  This probably is not needed but is here for
completeness' sake.

=cut

sub session
{
  my ( $self ) = @_;

  return $self->{_session};
}

=item IANAifType

Converts from an IANAifType integer value as will be returned by ifType
to its text equivalent.

=cut

sub IANAifType
{
   my ( $self, $iftype ) = @_;

   if ( defined $iftype )
   {
     return exists $IANAifType{$iftype} ? $IANAifType{$iftype} : 'other';
   }
   else
   {
     return $IANAifType{$self->ifType()} || 'other';
   }
}

=for pod

=back


The remainder of the methods are named after the literal names for the
SNMP entries for network interfaces.  The following descriptions are
taken from the IF-MIB with some additional comment from the author where
necessary.

=over

=item ifIndex

A unique value, greater than zero, for each
interface.  It is recommended that values are assigned
contiguously starting from 1.  The value for each
interface sub-layer must remain constant at least from
one re-initialization of the entity's network
management system to the next re-initialization.


=item ifDescr

A textual string containing information about the
interface.  This string should include the name of the
manufacturer, the product name and the version of the
interface hardware/software.

(In practice this will be name of the interface e.g. 'eth0')

=item ifType

The type of interface.  Additional values for ifType
are assigned by the Internet Assigned Numbers
Authority (IANA), through updating the syntax of the
IANAifType textual convention.


=item ifMtu

The size of the largest packet which can be
sent/received on the interface, specified in octets.
For interfaces that are used for transmitting network
datagrams, this is the size of the largest network
datagram that can be sent on the interface.


=item ifSpeed

An estimate of the interface's current bandwidth in
bits per second.  For interfaces which do not vary in
bandwidth or for those where no accurate estimation
can be made, this object should contain the nominal
bandwidth.  If the bandwidth of the interface is
greater than the maximum value reportable by this
object then this object should report its maximum
value (4,294,967,295) and ifHighSpeed must be used to
report the interace's speed.  For a sub-layer which
has no concept of bandwidth, this object should be
zero.


=item ifPhysAddress

The interface's address at its protocol sub-layer.
For example, for an 802.x interface, this object
normally contains a MAC address.  The interface's
media-specific MIB must define the bit and byte
ordering and the format of the value of this object.
For interfaces which do not have such an address
(e.g., a serial line), this object should contain an
octet string of zero length.


=item ifAdminStatus

The desired state of the interface.  The testing(3)
state indicates that no operational packets can be
passed.  When a managed system initializes, all
interfaces start with ifAdminStatus in the down(2)
state.  As a result of either explicit management
action or per configuration information retained by
the managed system, ifAdminStatus is then changed to
either the up(1) or testing(3) states (or remains in
the down(2) state).


=item ifOperStatus

The current operational state of the interface.  The
testing(3) state indicates that no operational packets
can be passed.  If ifAdminStatus is down(2) then
ifOperStatus should be down(2).  If ifAdminStatus is
changed to up(1) then ifOperStatus should change to
up(1) if the interface is ready to transmit and
receive network traffic; it should change to
dormant(5) if the interface is waiting for external
actions (such as a serial line waiting for an incoming
connection); it should remain in the down(2) state if
and only if there is a fault that prevents it from
going to the up(1) state; it should remain in the
notPresent(6) state if the interface has missing
(typically, hardware) components.


=item ifLastChange

The value of sysUpTime at the time the interface
entered its current operational state.  If the current
state was entered prior to the last re-initialization
of the local network management subsystem, then this
object contains a zero value.


=item ifInOctets

The total number of octets received on the interface,
including framing characters.
Discontinuities in the value of this counter can occur
at re-initialization of the management system, and at
other times as indicated by the value of
ifCounterDiscontinuityTime.


=item ifInUcastPkts

The number of packets, delivered by this sub-layer to
a higher (sub-)layer, which were not addressed to a
multicast or broadcast address at this sub-layer.
Discontinuities in the value of this counter can occur
at re-initialization of the management system, and at
other times as indicated by the value of
ifCounterDiscontinuityTime.


=item ifInNUcastPkts

The number of packets, delivered by this sub-layer to
a higher (sub-)layer, which were addressed to a
multicast or broadcast address at this sub-layer.
Discontinuities in the value of this counter can occur
at re-initialization of the management system, and at
other times as indicated by the value of
ifCounterDiscontinuityTime.
This object is deprecated in favour of
ifInMulticastPkts and ifInBroadcastPkts.


=item ifInDiscards

The number of inbound packets which were chosen to be
discarded even though no errors had been detected to
prevent their being deliverable to a higher-layer
protocol.  One possible reason for discarding such a
packet could be to free up buffer space.
Discontinuities in the value of this counter can occur
at re-initialization of the management system, and at
other times as indicated by the value of
ifCounterDiscontinuityTime.


=item ifInErrors

For packet-oriented interfaces, the number of inbound
packets that contained errors preventing them from
being deliverable to a higher-layer protocol.  For
character-oriented or fixed-length interfaces, the
number of inbound transmission units that contained
errors preventing them from being deliverable to a
higher-layer protocol.
Discontinuities in the value of this counter can occur
at re-initialization of the management system, and at
other times as indicated by the value of
ifCounterDiscontinuityTime.


=item ifInUnknownProtos

For packet-oriented interfaces, the number of packets
received via the interface which were discarded
because of an unknown or unsupported protocol.  For
character-oriented or fixed-length interfaces that
support protocol multiplexing the number of
transmission units received via the interface which
were discarded because of an unknown or unsupported
protocol.  For any interface that does not support
protocol multiplexing, this counter will always be 0.
Discontinuities in the value of this counter can occur
at re-initialization of the management system, and at
other times as indicated by the value of
ifCounterDiscontinuityTime.


=item ifOutOctets

The total number of octets transmitted out of the
interface, including framing characters.
Discontinuities in the value of this counter can occur
at re-initialization of the management system, and at
other times as indicated by the value of
ifCounterDiscontinuityTime.


=item ifOutUcastPkts

The total number of packets that higher-level
protocols requested be transmitted, and which were not
addressed to a multicast or broadcast address at this
sub-layer, including those that were discarded or not
sent.
Discontinuities in the value of this counter can occur
at re-initialization of the management system, and at
other times as indicated by the value of
ifCounterDiscontinuityTime.


=item ifOutNUcastPkts

The total number of packets that higher-level
protocols requested be transmitted, and which were
addressed to a multicast or broadcast address at this
sub-layer, including those that were discarded or not
sent.
Discontinuities in the value of this counter can occur
at re-initialization of the management system, and at
other times as indicated by the value of
ifCounterDiscontinuityTime.
This object is deprecated in favour of
ifOutMulticastPkts and ifOutBroadcastPkts.


=item ifOutDiscards

The number of outbound packets which were chosen to
be discarded even though no errors had been detected
to prevent their being transmitted.  One possible
reason for discarding such a packet could be to free
up buffer space.
Discontinuities in the value of this counter can occur
at re-initialization of the management system, and at
other times as indicated by the value of
ifCounterDiscontinuityTime.


=item ifOutErrors

For packet-oriented interfaces, the number of
outbound packets that could not be transmitted because
of errors.  For character-oriented or fixed-length
interfaces, the number of outbound transmission units
that could not be transmitted because of errors.
Discontinuities in the value of this counter can occur
at re-initialization of the management system, and at
other times as indicated by the value of
ifCounterDiscontinuityTime.


=item ifOutQLen

The length of the output packet queue (in packets).


=item ifSpecific

A reference to MIB definitions specific to the
particular media being used to realize the interface.
It is recommended that this value point to an instance
of a MIB object in the media-specific MIB, i.e., that
this object have the semantics associated with the
InstancePointer textual convention defined in RFC
1903.  In fact, it is recommended that the media-
specific MIB specify what value ifSpecific should/can
take for values of ifType.  If no MIB definitions
specific to the particular media are available, the
value should be set to the OBJECT IDENTIFIER { 0 0 }.

=back

=cut

sub AUTOLOAD
{
  my ( $self ) = @_;

  return if $AUTOLOAD =~ /DESTROY$/;

  my ($name) = $AUTOLOAD =~ /::([^:]+)$/;
   
  if ( not exists $OIDS{$name} ) 
  {
   croak "Can't locate object method '$name' via package '" . __PACKAGE__ . "'";
  }

  my $oid = "$OIDS{$name}." . $self->index();

  my $response;

  if ( defined( $response = $self->session()->get_request($oid)) )
  {
    return $response->{$oid};
  }
  else
  {
    return undef;
  }
    
}

1;
__END__

=head1 AUTHOR

Jonathan Stowe <jns@gellyfish.com>

=head1 COPYRIGHT

Copyright (c) Jonathan Stowe 2000.  All rights reserved.  This is free
software it can be distributed and/or modified under the same terms as
Perl itself.

=head1 SEE ALSO

perl(1), Net::SNMP, Net::SNMP::Interfaces.

=cut

