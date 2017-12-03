with Ada.Text_IO; use Ada.Text_IO;

procedure Inverse_Captcha_Part_2 is
    Input : String := Get_Line;
    Sum : Integer := 0;
    Other_Index : Integer;
    Len : Integer := Input'Length;
begin
    for I in 1 .. Len loop
        Other_Index := I + Len/2;
        if Other_Index > Len then
            Other_Index := Other_Index - Len;
        end if;
        if Input(I) = Input(Other_Index) then
            Sum := Sum + Integer'Value("" & Input(I)); -- Integer'Value takes a String, not a Character
        end if;
    end loop;
    Put_Line("checksum: " & Integer'Image(Sum));
end Inverse_Captcha_Part_2;
