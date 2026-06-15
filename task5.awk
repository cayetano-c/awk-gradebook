NR > 1 && $3 == "Q01" {
    sum += $4
    count++
}
END {
    if (count > 0) {
        print sum / count
    }
}