## Task 1
Command: awk -F',' 'NR>1{c++} END{print c}' Lab03-data.csv
Result: 322
Explanation: It skips the header row using NR>1, increments a counter variable 'c' for every subsequent record processed, and prints the final accumulated total in the END block.

## Task 2
Command: awk -F',' 'NR>1 && !seen[$1]++{n++} END{print n}' Lab03-data.csv
Result: 14
Explanation: It filters out duplicate student names by tracking them within an associative array named 'seen' as keys. The counter 'n' is incremented only when a student name is encountered for the first time, outputting the total number of unique students at the end.

## Task 3
Command: awk -F',' '$3=="FINAL"{printf "%-10s %3d\n",$1,$4}' Lab03-data.csv
Result:
Tomas       74
Diana       52
Andrew      61
Lucia       77
Kenji       72
Chelsey     52
Eliza       70
Shane       81
Noah        54
Ava         68
Maria       65
Priya       61
Jackson     66
Sam         62
Explanation: It checks each row to see if the assignment type in the third column matches the literal string FINAL. For every matching row, it uses printf with left-alignment flags to print the student name and their corresponding grade in a perfectly spaced column structure.

## Task 4
Command: awk -F',' 'NR>1 && $4 < 0.6*$5 {c++} END{print c}' Lab03-data.csv
Result: 121
Explanation: It skips the column headers and applies a conditional statement to evaluate if the points earned in the fourth column are strictly lower than sixty percent of the maximum possible points specified in the fifth column. It increments 'c' for each failing score to output the total count at the end.

## Task 5
Command: awk -F',' -f task5.awk Lab03-data.csv
Result:
Name        Low  High   Average
Q06           8    20     14.71
L05          17    50     38.21
WS            2     5      4.21
L06          27    50     40.07
Q07          12    20     15.36
L07          21    50     38.43
H01          46   100     82.71
H02          55   100     77.57
H03          62   100     82.43
H04          32    97     72.93
H05          51   100     74.00
H06          37    98     74.21
H07          40   100     72.93
Q01           9    20     14.29
L01          27    50     40.21
Q02           9    20     14.86
L02          23    50     39.21
Q03           8    20     15.07
L03          19    50     36.57
Q04          13    20     16.43
FINAL       116   200    156.86
Q05           8    18     15.07
L04          25    50     40.36
Explanation: The script loops through the dataset to accumulate grades, compute counts, and track minimum and maximum boundaries for each individual assignment type key. The END block iterates over these associative structures to print a formatted table showing the low, high, and calculated averages.

## Task 6
Command: awk -F',' -f task6.awk Lab03-data.csv
Result:
Tomas        82.22 B
Diana        62.08 D
Andrew       73.69 C
Lucia        89.53 B
Kenji        86.45 B
Chelsey      62.65 D
Eliza        84.16 B
Shane        93.12 A
Noah         63.08 D
Ava          81.43 B
Maria        79.57 C
Priya        71.04 C
Jackson      78.64 C
Sam          72.90 C
Explanation: It aggregates both the accumulated points earned and total achievable points per student using two distinct associative arrays. In its END execution phase, it computes the final percentage and evaluates it against an if/else if conditional sequence to assign and display the matching scale letter grade.

## Task 7
Command: ./run.sh Lab03-data.csv
Result:
Name       Percent Letter
Andrew       73.69 C
Ava          81.43 B
Chelsey      62.65 D
Diana        62.08 D
Eliza        84.16 B
Jackson      78.64 C
Kenji        86.45 B
Lucia        89.53 B
Maria        79.57 C
Noah         63.08 D
Priya        71.04 C
Sam          72.90 C
Shane        93.12 A
Tomas        82.22 B
Explanation: This shell script wraps around the task6 AWK execution by dynamically accepting the source file path via a standard argument variable ($1). It outputs the structural column header fields first and streams the per-student record outcomes directly through a sort pipe to alphabetize the records neatly.

## Bonus
Command: ./run.sh Lab03-data.csv
Result:
Name       Percent Letter
Andrew         73.69 C
Ava            81.43 B
CLASS          77.18 
Chelsey        62.65 D
Diana          62.08 D
Eliza          84.16 B
Jackson        78.64 C
Kenji          86.45 B
Lucia          89.53 B
Maria          79.57 C
Noah           63.08 D
Priya          71.04 C
Sam            72.90 C
Shane          93.12 A
Tomas          82.22 B
Explanation: The AWK script includes additional accumulator logic inside its primary evaluation loop to log every processed student percentage and keep a simple tally counter. Once the output loop concludes, it divides the gross sum by the counter and appends a dedicated class row showing the accurate average of the entire class group.