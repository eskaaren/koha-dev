#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 13;

use C4::Biblio;
use C4::Context;
use C4::Branch;
use C4::Members;

use C4::VirtualShelves;

use_ok( "C4::Utils::DataTables::VirtualShelves" );

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM virtualshelves|);

# Pick a categorycode from the DB
my @categories   = C4::Category->all;
my $categorycode = $categories[0]->categorycode;
my $branchcode   = "ABC";
my $branch_data = {
    add            => 1,
    branchcode     => $branchcode,
    branchname     => 'my branchname',
};
ModBranch( $branch_data );

my %john_doe = (
    cardnumber   => '123456',
    firstname    => 'John',
    surname      => 'Doe',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'john.doe',
);

my %jane_doe = (
    cardnumber   => '234567',
    firstname    =>  'Jane',
    surname      => 'Doe',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'jane.doe',
);
my %john_smith = (
    cardnumber   => '345678',
    firstname    =>  'John',
    surname      => 'Smith',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'john.smith',
);

$john_doe{borrowernumber} = AddMember( %john_doe );
$jane_doe{borrowernumber} = AddMember( %jane_doe );
$john_smith{borrowernumber} = AddMember( %john_smith );

my $shelf1 = {
    shelfname => 'my first private list (empty)',
    category => 1, # private
    sortfield => 'author',
};
$shelf1->{shelfnumber} = C4::VirtualShelves::AddShelf( $shelf1, $john_doe{borrowernumber} );

my $shelf2 = {
    shelfname => 'my second private list',
    category => 1, # private
    sortfield => 'title',
};
$shelf2->{shelfnumber} = C4::VirtualShelves::AddShelf( $shelf2, $john_doe{borrowernumber} );
my $biblionumber1 = _add_biblio('title 1');
my $biblionumber2 = _add_biblio('title 2');
my $biblionumber3 = _add_biblio('title 3');
my $biblionumber4 = _add_biblio('title 4');
my $biblionumber5 = _add_biblio('title 5');
C4::VirtualShelves::AddToShelf( $biblionumber1, $shelf2->{shelfnumber}, $john_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber2, $shelf2->{shelfnumber}, $john_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber3, $shelf2->{shelfnumber}, $john_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber4, $shelf2->{shelfnumber}, $john_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber5, $shelf2->{shelfnumber}, $john_doe{borrowernumber} );

my $shelf3 = {
    shelfname => 'The first public list',
    category => 2, # public
    sortfield => 'author',
};
$shelf3->{shelfnumber} = C4::VirtualShelves::AddShelf( $shelf3, $jane_doe{borrowernumber} );
my $biblionumber6 = _add_biblio('title 6');
my $biblionumber7 = _add_biblio('title 7');
my $biblionumber8 = _add_biblio('title 8');
C4::VirtualShelves::AddToShelf( $biblionumber6, $shelf3->{shelfnumber}, $jane_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber7, $shelf3->{shelfnumber}, $jane_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber8, $shelf3->{shelfnumber}, $jane_doe{borrowernumber} );

my $shelf4 = {
    shelfname => 'my second public list',
    category => 2, # public
    sortfield => 'title',
};
$shelf4->{shelfnumber}  = C4::VirtualShelves::AddShelf( $shelf4, $jane_doe{borrowernumber} );
my $biblionumber9  = _add_biblio('title 9');
my $biblionumber10 = _add_biblio('title 10');
my $biblionumber11 = _add_biblio('title 11');
my $biblionumber12 = _add_biblio('title 12');
C4::VirtualShelves::AddToShelf( $biblionumber9,  $shelf4->{shelfnumber}, $jane_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber10, $shelf4->{shelfnumber}, $jane_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber11, $shelf4->{shelfnumber}, $jane_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber12, $shelf4->{shelfnumber}, $jane_doe{borrowernumber} );

my $shelf5 = {
    shelfname => 'my third private list',
    category => 1, # private
    sortfield => 'title',
};
$shelf5->{shelfnumber} = C4::VirtualShelves::AddShelf( $shelf5, $jane_doe{borrowernumber} );
my $biblionumber13 = _add_biblio('title 13');
my $biblionumber14 = _add_biblio('title 14');
my $biblionumber15 = _add_biblio('title 15');
my $biblionumber16 = _add_biblio('title 16');
my $biblionumber17 = _add_biblio('title 17');
my $biblionumber18 = _add_biblio('title 18');
C4::VirtualShelves::AddToShelf( $biblionumber13, $shelf5->{shelfnumber}, $jane_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber14, $shelf5->{shelfnumber}, $jane_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber15, $shelf5->{shelfnumber}, $jane_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber16, $shelf5->{shelfnumber}, $jane_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber17, $shelf5->{shelfnumber}, $jane_doe{borrowernumber} );
C4::VirtualShelves::AddToShelf( $biblionumber18, $shelf5->{shelfnumber}, $jane_doe{borrowernumber} );

C4::VirtualShelves::AddShelf( { shelfname => 'another public list 6', category => 2}, $john_smith{borrowernumber} );
C4::VirtualShelves::AddShelf( { shelfname => 'another public list 7', category => 2}, $john_smith{borrowernumber} );
C4::VirtualShelves::AddShelf( { shelfname => 'another public list 8', category => 2}, $john_smith{borrowernumber} );
C4::VirtualShelves::AddShelf( { shelfname => 'another public list 9', category => 2}, $john_smith{borrowernumber} );
C4::VirtualShelves::AddShelf( { shelfname => 'another public list 10', category => 2}, $john_smith{borrowernumber} );
C4::VirtualShelves::AddShelf( { shelfname => 'another public list 11', category => 2}, $john_smith{borrowernumber} );
C4::VirtualShelves::AddShelf( { shelfname => 'another public list 12', category => 2}, $john_smith{borrowernumber} );
C4::VirtualShelves::AddShelf( { shelfname => 'another public list 13', category => 2}, $john_smith{borrowernumber} );
C4::VirtualShelves::AddShelf( { shelfname => 'another public list 14', category => 2}, $john_smith{borrowernumber} );
C4::VirtualShelves::AddShelf( { shelfname => 'another public list 15', category => 2}, $john_smith{borrowernumber} );



# Set common datatables params
my %dt_params = (
    iDisplayLength   => 10,
    iDisplayStart    => 0
);
my $search_results;

C4::Context->_new_userenv ('DUMMY_SESSION_ID');
C4::Context->set_userenv($john_doe{borrowernumber}, $john_doe{userid}, 'usercnum', 'First name', 'Surname', 'MYLIBRARY', 'My Library', 0);

# Search private lists by title
$search_results = C4::Utils::DataTables::VirtualShelves::search({
    shelfname => "ist",
    dt_params => \%dt_params,
    type => 1,
});

is( $search_results->{ iTotalRecords }, 2,
    "There should be 2 private shelves in total" );

is( $search_results->{ iTotalDisplayRecords }, 2,
    "There should be 2 private shelves with title like '%ist%" );

is( @{ $search_results->{ shelves } }, 2,
    "There should be 2 private shelves returned" );

# Search by type only
$search_results = C4::Utils::DataTables::VirtualShelves::search({
    dt_params => \%dt_params,
    type => 2,
});
is( $search_results->{ iTotalRecords }, 12,
    "There should be 12 public shelves in total" );

is( $search_results->{ iTotalDisplayRecords }, 12,
    "There should be 12 private shelves" );

is( @{ $search_results->{ shelves } }, 10,
    "There should be 10 public shelves returned" );

# Search by owner
$search_results = C4::Utils::DataTables::VirtualShelves::search({
    owner => "jane",
    dt_params => \%dt_params,
    type => 2,
});
is( $search_results->{ iTotalRecords }, 12,
    "There should be 12 public shelves in total" );

is( $search_results->{ iTotalDisplayRecords }, 2,
    "There should be 1 public shelves for jane" );

is( @{ $search_results->{ shelves } }, 2,
    "There should be 1 public shelf returned" );

# Search by owner and shelf name
$search_results = C4::Utils::DataTables::VirtualShelves::search({
    owner => "smith",
    shelfname => "public list 1",
    dt_params => \%dt_params,
    type => 2,
});
is( $search_results->{ iTotalRecords }, 12,
    "There should be 12 public shelves in total" );

is( $search_results->{ iTotalDisplayRecords }, 6,
    "There should be 6 public shelves for john with name like %public list 1%" );

is( @{ $search_results->{ shelves } }, 6,
    "There should be 6 public chalves returned" );

sub _add_biblio {
    my ( $title ) = @_;
    my $biblio = MARC::Record->new();
    $biblio->append_fields(
        MARC::Field->new('245', ' ', ' ', a => $title),
    );
    my ($biblionumber, $biblioitemnumber) = AddBiblio($biblio, '');
    return $biblionumber;
}

1;
