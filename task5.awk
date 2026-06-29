# Task 5 - Assignment Metrics Report
NR>1 { 
    s[$3]+=$4
    n[$3]++
    if(!($3 in lo)||$4<lo[$3]) lo[$3]=$4
    if(!($3 in hi)||$4>hi[$3]) hi[$3]=$4 
}
END { 
    printf "%-8s %5s %5s %9s\n","Name","Low","High","Average"
    for(a in s) printf "%-8s %5d %5d %9.2f\n",a,lo[a],hi[a],s[a]/n[a] 
}