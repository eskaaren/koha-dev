<script type="text/javascript">
//<![CDATA[
function keep_text(clicked) {
    var queries = document.getElementsByClassName("query");
    var persist = queries[0].value;

    for (i = 0; i < queries.length - 1; i++) {
        if (queries[i].value != queries[i+1].value) {
            if (i === queries.length-2) {
                if (queries[i].value != queries[0].value) {
                    persist = queries[i].value;
                } else if (queries.length === 2) {
                    if (clicked === 0) {
                        persist = queries[1].value;
                    }
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
//]]>
</script>
