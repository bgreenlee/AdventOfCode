GET "libhdr"

LET start() = VALOF
{
    LET checksum = 0
    LET curnum = 0
    LET row = VEC 16
    LET col = 0

    writes("Enter data, type '.' when finished:*n")
    {
        LET ch = rdch()
        IF ch = endstreamch | ch='.' BREAK
        TEST ch>=48 & ch<=57 THEN
        {
            curnum := curnum * 10 + (ch - 48)
        }
        ELSE
        {
            row!col := curnum
            col := col + 1
            curnum := 0
        }

        IF ch = 10 & col > 0 THEN
        {
            FOR i = 0 TO col - 2 DO
            {
                FOR j = i + 1 TO col - 1 DO
                {
                    TEST row!i MOD row!j = 0 THEN
                    {
                        checksum := checksum + row!i / row!j
                        GOTO next
                    }
                    ELSE IF row!j MOD row!i = 0 THEN
                    {
                        checksum := checksum + row!j / row!i
                        GOTO next
                    }
                }
            }
        next:
            col := 0
        }
    } REPEAT

    sawritef("checksum = %i *n*n", checksum)
    RESULTIS 0
}