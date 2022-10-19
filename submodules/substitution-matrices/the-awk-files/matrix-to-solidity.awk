#!/usr/bin/awk -f

function print_result() {
  print "int["length(arr[1])"]["length(arr)"] matrix = [";
  
  for(i = 0; i < length(arr); i++) {
    str = "";
    for(j = 0; j < length(arr[i]); j++) {
      str = j == 0 ? "[int("arr[i][j]")" : str", "arr[i][j];
    }
    if(str) print i + 1 == length(arr) ? str"]" : str"],";
  }

  print "];";
}

BEGIN {
  line = 0;
}

NF {
  split($0, a, /\s+/);
  
  count = 0;
  for (i = 0; i < length(a); i++) {
    if(a[i] ~ /^[-]?[0-9]+$/) {
      arr[line][count] = a[i];
      count++;
    }
  }

  line++;
}

END {
  print_result();
}