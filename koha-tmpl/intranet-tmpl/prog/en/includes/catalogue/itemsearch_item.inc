[%- USE Branches -%]
[% biblio = item.biblio %]
[% biblioitem = item.biblioitem %]
<tr>
  <td>
    <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblio.biblionumber %]" title="Go to record detail page">[% biblio.title %]</a>
    by [% biblio.author %]
  </td>
  <td>[% biblioitem.publicationyear %]</td>
  <td>[% biblioitem.publishercode %]</td>
  <td>[% biblioitem.collectiontitle %]</td>
  <td>
    <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% biblio.biblionumber %]#item[% item.itemnumber %]" title="Go to item details">[% item.barcode %]</a>
  </td>
  <td>[% item.itemcallnumber %]</td>
  <td>[% Branches.GetName(item.homebranch) %]</td>
  <td>[% Branches.GetName(item.holdingbranch) %]</td>
  <td>[% item.location %]</td>
  <td>[% item.stocknumber %]</td>
  <td>[% item.status %]</td>
  <td>[% item.issues || 0 %]</td>
  <td><a href="/cgi-bin/koha/cataloguing/additem.pl?op=edititem&biblionumber=[% item.biblionumber %]&itemnumber=[% item.itemnumber %]">Edit</a></td>
</tr>