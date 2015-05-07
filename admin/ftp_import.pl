#!/usr/bin/perl

use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth;
use C4::Output;
use Module::Load::Conditional qw(can_load);
use JSON;
use Modern::Perl;

my $input = new CGI;
my ($template, $loggedinuser, $cookie);

if ($input->param()) {
    ($template, $loggedinuser, $cookie)
        = get_template_and_user({template_name => "admin/ftp_import_result.tt",
            query => $input,
            type => "intranet",
            authnotrequired => 0,
            flagsrequired => {parameters => 'parameters_remaining_permissions'},
            debug => 1,
            });
    my $params = $input->Vars();
    my $file = "/tmp/ftp_import.yml";
    open (my $fh, ">", "$file") or die "Cannot open $file: $!";
    for my $k (keys %$params) {
        print $fh "$k: \"$params->{$k}\"\n";
    }
    print $fh "ftp_debug: 1\nsubtract_hours: 0\nlocal_dir: \"/tmp/\"\n";
    print $fh "952a: 'X'\n952b: 'X'\n952y: 'ONORDER'\n";
    close $fh;

    #$template->{VARS}->{output} = `/usr/bin/perl $params->{ftp2koha} --config $file -v 2>&1`;
    my @out = `/usr/bin/perl $params->{ftp2koha} --config $file -v 2>&1`;
    $template->{VARS}->{output} = join('<br>', @out);
} else {
     ($template, $loggedinuser, $cookie)
        = get_template_and_user({template_name => "admin/ftp_import.tt",
            query => $input,
            type => "intranet",
            authnotrequired => 0,
            flagsrequired => {parameters => 'parameters_remaining_permissions'},
            debug => 1,
            });
}
output_html_with_http_headers $input, $cookie, $template->output;
