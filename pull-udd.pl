#!/usr/bin/perl

# $1: UDD dump file to generate


$^W = 1;
use strict;
use DBI;
use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Sortkeys = 1;  # stable output
$Data::Dumper::Purity = 1; # recursive structures must be safe

#my $limit = " limit 10";
my $limit = "";

my $udd = DBI->connect("DBI:Pg:dbname=udd;host=public-udd-mirror.xvm.mit.edu", "public-udd-mirror", "public-udd-mirror");

# Column names:
#
# source version maintainer maintainer_name maintainer_email format files uploaders bin architecture standards_version homepage build_depends build_depends_indep build_conflicts build_conflicts_indep priority section distribution release component vcs_type vcs_url vcs_browser python_version ruby_versions checksums_sha1 checksums_sha256 original_maintainer dm_upload_allowed testsuite autobuild extra_source_only


# Getting source packages...
# (from 'sources' table)
#
my $srcquery = $udd->prepare("SELECT source, version, maintainer_email, maintainer_name, release, uploaders, bin, architecture, build_depends, build_depends_indep, build_conflicts, build_conflicts_indep FROM sources$limit");
#
my $sources;
my $ret_sources = $srcquery->execute();
if ($ret_sources) {
  $sources = $srcquery->fetchall_arrayref;
} else {
  die("Cannot get source packages: $!");
}


# Getting binary packages...
# (from 'packages' table)
#
my $packquery = $udd->prepare("SELECT package, version, maintainer_email, maintainer_name, release, description, depends, recommends, suggests, conflicts, breaks, provides, replaces, pre_depends, enhances FROM packages$limit");
#
my $packages;
my $ret_packages = $packquery->execute();
if ($ret_packages) {
  $packages = $packquery->fetchall_arrayref;
} else {
  die("Cannot get binary packages $!");
}


# Writing to file...
#
$out_filename =~ s#^(\s)#./$1#;
open(my $fd, "> $out_filename\0") || die "Can't open $out_filename for writing: $!");
#
# The 'qw(sources packages)' interface must match the ones in 'read_sources_file()' and 'read_packages_file()', from 'generate-graph.pl'.
print $fd Data::Dumper->Dump([\$sources, \$packages], [qw(sources packages)]);
