use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Net::SNMP::Interfaces',
    'VERSION_FROM'	=> 'Interfaces.pm', # finds $VERSION
    'PREREQ_PM'		=> {'Net::SNMP' => 3.5 }, 
    'PMLIBDIRS'         => ['Details'],
);
