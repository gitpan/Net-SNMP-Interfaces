use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		=> 'Net::SNMP::Interfaces',
    'VERSION_FROM'	=> 'lib/Net/SNMP/Interfaces.pm', 
    'PREREQ_PM'		=> {'Net::SNMP' => 3.5,
                         'Test::More' => 0.47 }, 
);
