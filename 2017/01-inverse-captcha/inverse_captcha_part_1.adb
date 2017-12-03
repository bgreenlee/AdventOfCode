with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

procedure Inverse_Captcha_Part_1 is
    Input : Unbounded_String := To_Unbounded_String(Get_Line);
    Sum : Integer := 0;
begin
    Input := Input & Element(Input, 1); -- handle wrap-around by appending the first character
    for I in 1 .. Length(Input) - 1 loop
        if Element(Input, I) = Element(Input, I + 1) then
            Sum := Sum + Integer'Value("" & Element(Input, I)); -- Integer'Value takes a String, not a Character
        end if;
    end loop;
    Put_Line("checksum: " & Integer'Image(Sum));
end Inverse_Captcha_Part_1;
