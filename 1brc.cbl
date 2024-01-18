      *****************************************************************
      * Program name:    ONEBRCCBL
      * Original author: Robin Kristiansen
      *
      * Description: a [naive] COBOL solution for Gunnar Morling's
      *    One Billion Row Challenge: 
      *    (https://github.com/gunnarmorling/1brc)
      *
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID.  ONEBRCCBL.
       AUTHOR. Robin Kristiansen.
       DATE-WRITTEN. 18.01.2024
       DATE-COMPILED. 18.01.2024.
      *****************************************************************

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.  
       FILE-CONTROL.
      *    SELECT INPUT-FILE ASSIGN TO 'data/input.txt'
           SELECT INPUT-FILE ASSIGN USING FILENAME
              ORGANIZATION IS LINE SEQUENTIAL 
              ACCESS MODE IS SEQUENTIAL.

       DATA DIVISION. 
       FILE SECTION. 
       FD INPUT-FILE DATA RECORD IS REC.
       01 REC.
          05 REC-DATA-01           PIC X(110).
             88 FILE-EOF                             VALUE HIGH-VALUES.

       WORKING-STORAGE SECTION. 
       01 FILENAME                 PIC X(255).
       01 MEASUREMENT.
          05 MEAS-LOC              PIC X(100).
          05 MEAS-TEMP             PIC S9(2)V9 COMP-3.

       01 WS-TOTAL-COUNT           PIC 9(10)         VALUE ZERO.
       01 WS-UNIQ-COUNT            PIC 9(10)         VALUE ZERO.

       01 WS-FREE-IDX              PIC 9(3)          VALUE 1.

      ******************************************************************
      * There appears to be at most 413 different location names       *
      * Location names are at most 100 characters long                 *
      * On average, each location has 2,421,307 measurements           *
      *                                                                *
      * Temperature is on the form -99.9 (ex. -23.0 or 5.9)            *
      *                                                                *
      *    prefix..LOC      100 Characters                             *
      *    prefix..TEMP     Signed -99.9 to 99.9                       *
      *    prefix..COUNT    Up to 9,999,999 entries                    *
      ******************************************************************
       01 TBL-SIZE                 PIC 9(3)          VALUE 500.
       01 WS-MEASUREMENT-TBL.
          02 WS-MEASUREMENT OCCURS 1 TO 500 TIMES
                DEPENDING ON TBL-SIZE INDEXED BY WS-IDX.
             03 WS-MEAS-LOC        PIC X(100).
             03 WS-MEAS-MIN        PIC S9(2)V9 COMP-3. 
             03 WS-MEAS-MAX        PIC S9(2)V9 COMP-3. 
             03 WS-MEAS-MEAN       PIC S9(2)V9 COMP-3. 
             03 WS-MEAS-TOTALTEMP  PIC S9(9)V9 COMP-3. 
             03 WS-MEAS-COUNT      PIC 9(7).
      *    repr  only used for display, not for arithmetic
       77 DSPL-LOC                 PIC X(30).
      * PIC -99.9 makes -5.5 look like '-05.5'
      * PIC -Z9.9 makes -5.5 look like '- 5.5'
      * Find some way to nicely display negative numbers
       77 DSPL-MIN                 PIC -99.9 USAGE DISPLAY.
       77 DSPL-MEAN                PIC -99.9 USAGE DISPLAY.
       77 DSPL-MAX                 PIC -99.9 USAGE DISPLAY.
       77 DSPL-UNIQ                PIC Z,ZZZ,ZZZ,ZZZ.
       77 DSPL-CNT                 PIC Z,ZZZ,ZZZ,ZZZ.

       LINKAGE SECTION. 
       01 CMD-INPUT                PIC X(255).

       PROCEDURE DIVISION USING CMD-INPUT.
       1000-MAIN-PARA.
           MOVE CMD-INPUT TO FILENAME
           OPEN INPUT INPUT-FILE.

           PERFORM FETCH-RECORDS
           
           CLOSE INPUT-FILE.

           PERFORM CALCULATE-MEANS.

           PERFORM SORT-TABLE.

           PERFORM PRODUCE-OUTPUT.

           GOBACK.

       FETCH-RECORDS.
           PERFORM UNTIL FILE-EOF
                   READ INPUT-FILE INTO REC
                   AT END
                      SET FILE-EOF TO TRUE
                   NOT AT END
                       ADD 1 TO WS-TOTAL-COUNT 
                       PERFORM PARSE-RECORD
                   END-READ
           END-PERFORM
           EXIT.

       PARSE-RECORD.
           UNSTRING REC DELIMITED BY ';'
              INTO MEAS-LOC
                   MEAS-TEMP.
           IF MEAS-LOC NOT = SPACE THEN
              PERFORM FIND-ENTRY
           END-IF
           EXIT.

       FIND-ENTRY.
           SET WS-IDX TO 1
      *    TODO: optimization:
      *       Find a way to use SEARCH ALL (binary search)
      *       Table must to be sorted beforehand though
           SEARCH WS-MEASUREMENT VARYING WS-IDX 
           AT END
              PERFORM NOT-FOUND
           WHEN WS-MEAS-LOC(WS-IDX) = MEAS-LOC 
                PERFORM FOUND
           END-SEARCH.


       NOT-FOUND.
      *    Add new entry
      *    TODO: check if we have any free indexes left
      *    i.e. if ws-free-idx >= max-table-size or something
           SET WS-IDX TO WS-FREE-IDX.
           ADD 1 TO WS-FREE-IDX.
           ADD 1 TO WS-UNIQ-COUNT.

           MOVE 1 TO WS-MEAS-COUNT(WS-IDX).
           MOVE MEAS-LOC TO WS-MEAS-LOC(WS-IDX).
           MOVE MEAS-TEMP TO WS-MEAS-MIN(WS-IDX).
           MOVE MEAS-TEMP TO WS-MEAS-MAX(WS-IDX).
           MOVE MEAS-TEMP TO WS-MEAS-TOTALTEMP(WS-IDX).
           EXIT.

       FOUND.
      *    Add to existing entry
      *    Accumulate total temp and calculate/check min/max
           ADD 1 TO WS-MEAS-COUNT(WS-IDX).

           ADD MEAS-TEMP TO WS-MEAS-TOTALTEMP(WS-IDX).

           IF MEAS-TEMP < WS-MEAS-MIN(WS-IDX) THEN
              MOVE MEAS-TEMP TO WS-MEAS-MIN(WS-IDX)
           END-IF

           IF MEAS-TEMP > WS-MEAS-MAX(WS-IDX) THEN
              MOVE MEAS-TEMP TO WS-MEAS-MAX(WS-IDX)
           END-IF
              
           EXIT.

       CALCULATE-MEANS.
           PERFORM VARYING WS-IDX
              FROM 1 BY 1 UNTIL WS-IDX > WS-UNIQ-COUNT
                   COMPUTE WS-MEAS-MEAN(WS-IDX) ROUNDED =
                      WS-MEAS-TOTALTEMP(WS-IDX) / WS-MEAS-COUNT
                      (WS-IDX)
                   END-COMPUTE
           END-PERFORM

           EXIT.

       SORT-TABLE.
           SORT WS-MEASUREMENT ASCENDING WS-MEAS-LOC.
           EXIT.

       
      *PRINT-TABLE.
      *    MOVE WS-TOTAL-COUNT TO DSPL-CNT.
      *    MOVE WS-UNIQ-COUNT TO DSPL-UNIQ.
      *    DISPLAY "Total: "
      *            FUNCTION TRIM(DSPL-CNT).
      *    DISPLAY
      *       "Total unique locations: "
      *       FUNCTION TRIM(DSPL-UNIQ).
      *    DISPLAY
      *       "LOCATION                  "
      *       WITH NO ADVANCING.
      *    DISPLAY "     MIN    MEAN     MAX".
      *    DISPLAY "--------------------------------------------------".
      *    COMPUTE WS-IDX = TBL-SIZE - WS-UNIQ-COUNT + 1.
      *    PERFORM VARYING WS-IDX
      *       FROM WS-IDX BY 1 UNTIL WS-IDX > TBL-SIZE 
      *            MOVE FUNCTION TRIM(WS-MEAS-LOC(WS-IDX)) TO DSPL-LOC
      *            MOVE WS-MEAS-MIN(WS-IDX) TO DSPL-MIN 
      *            MOVE WS-MEAS-MEAN(WS-IDX) TO DSPL-MEAN 
      *            MOVE WS-MEAS-MAX(WS-IDX) TO DSPL-MAX 
      *            DISPLAY DSPL-LOC
      *                    DSPL-MIN
      *                    "    "
      *                    DSPL-MEAN
      *                    "    "
      *                    DSPL-MAX
      *    END-PERFORM.
      *    EXIT.

       PRODUCE-OUTPUT.
           DISPLAY "{" WITH NO ADVANCING.
           COMPUTE WS-IDX = TBL-SIZE - WS-UNIQ-COUNT + 1.
           PERFORM VARYING WS-IDX
              FROM WS-IDX BY 1 UNTIL WS-IDX > TBL-SIZE 
                   MOVE FUNCTION TRIM(WS-MEAS-LOC(WS-IDX)) TO DSPL-LOC 
                   MOVE WS-MEAS-MIN(WS-IDX) TO DSPL-MIN 
                   MOVE WS-MEAS-MEAN(WS-IDX) TO DSPL-MEAN 
                   MOVE WS-MEAS-MAX(WS-IDX) TO DSPL-MAX 
                   DISPLAY
                      FUNCTION TRIM(DSPL-LOC)
                      "="
                      FUNCTION TRIM(DSPL-MIN)
                      "/"
                      FUNCTION TRIM(DSPL-MEAN)
                      "/"
                      FUNCTION TRIM(DSPL-MAX)
                      WITH NO ADVANCING 
                   IF WS-IDX < TBL-SIZE THEN
                      DISPLAY ", " WITH NO ADVANCING 
                   END-IF
           END-PERFORM.
           DISPLAY "}"
           EXIT.
