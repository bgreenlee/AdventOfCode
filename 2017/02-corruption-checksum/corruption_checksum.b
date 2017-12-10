GET "libhdr"

LET start() = VALOF
{
    LET largest = 0
    LET default_smallest = 9999999
    LET default_largest = 0
    LET smallest = default_smallest
    LET checksum = default_largest
    LET curnum = 0

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
            // sawritef("curnum=%i *n", curnum)
            IF curnum > largest DO largest := curnum
            IF curnum \= 0 & curnum < smallest DO smallest := curnum
            curnum := 0
        }

        IF ch = 10 & largest \= default_largest & smallest \= default_smallest THEN
        {
            checksum := checksum + largest - smallest
            // sawritef("largest = %i, smallest = %i, checksum = %i *n", largest, smallest, checksum)
            smallest := default_smallest
            largest := default_largest
        }

    } REPEAT

    sawritef("checksum = %i *n*n", checksum)
    RESULTIS 0
}