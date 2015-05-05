#!/usr/bin/perl

use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth;
use C4::Output;
use Module::Load::Conditional qw(can_load);
use JSON;
use Modern::Perl;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/ftp_import.tt",
            query => $input,
            type => "intranet",
            authnotrequired => 0,
            flagsrequired => {parameters => 'parameters_remaining_permissions'},
            debug => 1,
            });

output_html_with_http_headers $input, $cookie, $template->output;
