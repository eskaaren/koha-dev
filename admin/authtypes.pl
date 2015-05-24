#!/usr/bin/perl

# written 20/02/2002 by paul.poulain@free.fr

# Copyright 2000-2002 Katipo Communications
#
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
use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth;
use C4::Output;

sub StringSearch  {
    my $string = shift || '';
    my $dbh = C4::Context->dbh;
    return $dbh->selectall_arrayref(q|
        SELECT authtypecode, authtypetext, auth_tag_to_report, summary
        FROM auth_types
        WHERE (authtypecode like ?) ORDER BY authtypecode
    |, { Slice => {} }, $string . "%" );
}

my $input = new CGI;
my $script_name  = "/cgi-bin/koha/admin/authtypes.pl";
my $searchfield  = $input->param('authtypecode');  # FIXME: Auth Type search not really implemented
my $authtypecode = $input->param('authtypecode');
my $op           = $input->param('op')     || '';
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "admin/authtypes.tt",
                query => $input,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => {parameters => 'parameters_remaining_permissions'},
                debug => 1,
                });

$template->param(
    script_name => $script_name,
    ($op || 'else') => 1,
);

my $dbh = C4::Context->dbh;

# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
    #---- if primkey exists, it's a modify action, so read values to modify...
    if ( defined $authtypecode) {
        my $sth = $dbh->prepare("SELECT * FROM auth_types WHERE authtypecode=?");
        $sth->execute($authtypecode);
        my $data = $sth->fetchrow_hashref();
        $template->param(
            authtypecode       => $authtypecode,
            authtypetext       => $data->{'authtypetext'},
            auth_tag_to_report => $data->{'auth_tag_to_report'},
            summary            => $data->{'summary'},
        );
    }
                                                    # END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
    my $sth = $input->param('modif') ? 
            $dbh->prepare("UPDATE auth_types SET authtypetext=? ,auth_tag_to_report=?, summary=? WHERE authtypecode=?") :
            $dbh->prepare("INSERT INTO auth_types SET authtypetext=?, auth_tag_to_report=?, summary=?, authtypecode=?") ;
    $sth->execute($input->param('authtypetext'),$input->param('auth_tag_to_report'),$input->param('summary'),$input->param('authtypecode'));
    print $input->redirect($script_name);    # FIXME: unnecessary redirect
    exit;
                                                    # END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
    #start the page and read in includes
    my $sth=$dbh->prepare("SELECT count(*) AS total FROM auth_tag_structure WHERE authtypecode=?");
    $sth->execute($authtypecode);
    my $total = $sth->fetchrow_hashref->{total};

    my $sth2 = $dbh->prepare("SELECT * FROM auth_types WHERE authtypecode=?");
    $sth2->execute($authtypecode);
    my $data = $sth2->fetchrow_hashref;

    $template->param(authtypecode => $authtypecode,
                     authtypetext => $data->{'authtypetext'},
                          summary => $data->{'summary'},
                            total => $total);
                                                    # END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
    #start the page and read in includes
    my $sth=$dbh->prepare("DELETE FROM auth_types WHERE authtypecode=?");
    $sth->execute(uc $input->param('authtypecode'));
    print $input->redirect($script_name);   # FIXME: unnecessary redirect
    exit;
                                                    # END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
    my $results = StringSearch($searchfield);
    $template->param( loop => $results );
} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;
