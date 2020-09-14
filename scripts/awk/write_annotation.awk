BEGIN {
    # Set the field separator to anything except a space or a tab
    # and set all other values to 0
    FS="[^ \t]";
    seen_annotations=0
    within_annotations=0
    field_seen=0
}

{
    if (within_annotations==1 && ($0~/^ /) == 0) {
        # Since the first line here is not a space (i.e. indented)
        # we are no longer in the annotation section
        within_annotations=0
    }
}

{
    if (within_annotations==1 && $0~field) {
        # If we are within the annotation section and we see our
        # annotation, replace its contents with our new_val
        gsub(/: .*/, ": %s")
        gsub("%s", new_val)
        field_seen=1;
    }
}

{
    if (within_annotations==0 && seen_annotations==1 && field_seen==0) {
        # If we just crossed the end of the annotations field and we
        # haven't seen our annotation yet but are moving on to another section
        # of the Chart.yaml, add our annotation here with its new_val
        for(i=1;i<=curr_indent;i++) printf " "
        printf "%s: %s", field, new_val;
        print ""
        field_seen=1;
    }
}

/^annotations:/{
    # We have seen annotations and are currently
    # within the annotation section of the Chart.yaml
    within_annotations=1;
    seen_annotations=1
}

{curr_indent=length($1)}

{print}

END {
    # Handle edge cases
    if (seen_annotations==0) {
        # We never saw an annotation section, so we add an annotation
        # section and insert the value there
        print "annotations:"
        printf "  %s: %s", field, new_val;
        print ""
    } else if (field_seen==0) {
        # If we crossed the end of our annotations field and
        # we haven't seen our annotation yet but we have reached
        # the end of the file, add our annotation here with its new_val
        for(i=1;i<=curr_indent;i++) printf " "
        printf "%s: %s", field, new_val;
        print ""
    }
}