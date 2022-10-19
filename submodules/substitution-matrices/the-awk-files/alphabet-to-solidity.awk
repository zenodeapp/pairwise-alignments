#!/usr/bin/awk -f

NF {
  split($0, a, /\s+/);

  count = 0;
  for (i = 0; i < length(a); i++) {
    if(a[i] != "") {
      print "alphabet[\""a[i]"\"] = "count";";
      count++;
    }
  }
}