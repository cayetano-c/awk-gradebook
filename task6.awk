NR > 1 {
    points_earned[$1] += $4
    points_possible[$1] += $5
}
END {
    for (student in points_earned) {
        if (points_possible[student] > 0) {
            pct = (points_earned[student] / points_possible[student]) * 100
            
            if (pct >= 90) {
                grade = "A"
            } else if (pct >= 80) {
                grade = "B"
            } else if (pct >= 70) {
                grade = "C"
            } else if (pct >= 60) {
                grade = "D"
            } else {
                grade = "E"
            }
            
            printf "%s: %.2f%% (%s)\n", student, pct, grade
        }
    }
}