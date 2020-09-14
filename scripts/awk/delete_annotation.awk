BEGIN {
    # By default, we are not within the annotations section yet
    within_annotations=0;
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
        # annotation, just skip printing that line
        next
    }
}

# Check to see if we have entered the annotations part of the YAML file
/^annotations:/{within_annotations=1}

# print any values that haven't been skipped
{print}