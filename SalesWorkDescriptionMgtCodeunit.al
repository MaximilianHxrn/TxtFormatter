codeunit 55148 "SIT SalesWorkDescriptionMgt"
{
    Description = 'SC202159';
    SingleInstance = true;

    // SC202159
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnBeforeCreateSalesHeader', '', false, false)]
    local procedure CalcWorkDescriptionBeforeCreateSalesHeader(var SalesHeader: Record "Sales Header");
    begin
        if SalesHeader."Work Description".HasValue then
            SalesHeader.CalcFields("Work Description");
    end;

    // SC202159
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ArchiveManagement", 'SITEOnBeforeStoreSalesDocument', '', false, false)]
    local procedure CalcWorkDescriptionBeforeStoreSalesDocument(var SalesHeader: Record "Sales Header");
    begin
        if SalesHeader."Work Description".HasValue then
            SalesHeader.CalcFields("Work Description");
    end;

    // SC202159
    procedure GetWorkDescriptionArchive(var SalesHeaderArchive: Record "Sales Header Archive"): Text;
    var
        TempBlob: Record TempBlob;
        CR: Text[1];
    BEGIN
        with SalesHeaderArchive do
            if "Work Description".HasValue then begin
                CalcFields("Work Description");
                CR[1] := 10;
                TempBlob.Blob := "Work Description";
                exit(TempBlob.ReadAsText(CR, TextEncoding::UTF8));
            end;
    end;
}