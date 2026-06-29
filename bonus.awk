# Bonus - Class Average Calculation Extension
NR>1 { 
    earned[$1]+=$4
    poss[$1]+=$5 
}
END { 
    student_count = 0
    total_class_pct = 0
    for(st in earned){ 
        if(poss[st]>0){
            p=100*earned[st]/poss[st]
            if(p>=90)g="A";else if(p>=80)g="B";else if(p>=70)g="C";else if(p>=60)g="D";else g="E"
            printf "%-10s %7.2f %s\n",st,p,g 
            total_class_pct += p
            student_count++
        }
    } 
    if (student_count > 0) {
        printf "%-10s %7.2f \n", "CLASS", (total_class_pct / student_count)
    }
}