<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName %]</a></h1><!-- Begin Main page Resident Search Box -->

<div id="header_search">
    [% INCLUDE 'patron-search-box.inc' %]
[% IF ( CAN_user_circulate ) %]
<div id="checkin_search" class="residentsearch">
    <p class="tip">Scan a barcode to check in:</p>
    <form method="post" action="/cgi-bin/koha/circ/returns.pl" autocomplete="off">
        <input name="barcode" class="query" id="ret_barcode" size="40" accesskey="r" />
        <input value="Submit" class="submit" type="submit" />
    </form>
</div>[% END %]
[% IF ( CAN_user_borrowers ) %]
<div id="patron_search" class="residentsearch">
    <p class="tip">Enter patron card number or partial name:</p>
    <form action="/cgi-bin/koha/members/member.pl" method="post">
        <input name="searchmember" class="query" id="searchmember" size="40" type="text"/>
        <input type="hidden" name="quicksearch" value="1" />
        <input value="Submit" class="submit" type="submit" />
    </form>
</div>[% END %]
[% IF ( CAN_user_catalogue ) %]
<div id="catalog_search" class="residentsearch">
    <p class="tip">Enter search keywords:</p>
    <form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
        <input type="text" name="q" id="search-form" class="query" size="40" accesskey="q" />
        <input type="submit" class="submit" value="Submit"/>
    </form>
</div>[% END %]

<ul>
    [% IF ( CAN_user_circulate ) %]<li><a onclick="keep_text()" href="#circ_search">Check out</a></li>[% END %]
    [% IF ( CAN_user_circulate ) %]<li><a onclick="keep_text()" href="#checkin_search">Check in</a></li>[% END %]
    [% IF ( CAN_user_borrowers ) %]<li><a onclick="keep_text()" href="#patron_search">Search patrons</a></li>[% END %]
    [% IF ( CAN_user_catalogue ) %]<li><a onclick="keep_text()" href="#catalog_search">Search the catalog</a></li>[% END %]
</ul>

</div><!-- /header_search -->
</div><!-- /gradient -->
<!-- End Main page Resident Search Box -->
<style>
.query {
    width:600px;
}
</style>

<script>
function keep_text() {
    var  queries = document.getElementsByClassName("query");
    var persist = queries[0].value;
   
    for (i = 0; i < queries.length - 1; i++) {
        if (queries[i].value != queries[i+1].value) {
            if (i === queries.length-2) {
                if (queries[i].value != queries[0].value) {
                    persist = queries[i].value;
                } else {
                    persist = queries[i+1].value;
                }
            } else if (queries[i+1].value != queries[i+2].value) {
                persist = queries[i+1].value;
            }
        }
    }
 
    for (i = 0; i < queries.length; i++) {
        queries[i].value = persist;
    }
}
</script>
