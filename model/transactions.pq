let
 Source = Excel.Workbook(File.Contents(SourceWorkbook), null, true),
 Sheet = Source{[Item="inventory data",Kind="Sheet"]}[Data],
 Headers = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),
 Nonblank = Table.SelectRows(Headers, each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))),
 Filled = Table.FillDown(Nonblank, {"ITEM NAME","CATEGORY","UNIT","SPECIFICATION","PRIORITY"}),
 Dated = Table.SelectRows(Filled, each [DATE] <> null),
 Renamed = Table.RenameColumns(Dated, {{"ITEM NAME","ItemName"},{"CATEGORY","Category"},{"UNIT","Unit"},{"SPECIFICATION","Specification"},{"PRIORITY","Priority"},{"DATE","Date"},{"WORK ORDER","WorkOrder"},{"EQUIPMENT / ASSET","Asset"},{"RECEIVED","Received"},{"ISSUED","Issued"},{"REMAINING","Remaining"},{"UNIT PRICE (IDR)","UnitPrice"},{"INDEX","Index"}}),
 Typed = Table.TransformColumnTypes(Renamed, {{"ItemName",type text},{"Category",type text},{"Unit",type text},{"Specification",type text},{"Priority",type text},{"Date",type date},{"WorkOrder",type text},{"Asset",type text},{"Received",Int64.Type},{"Issued",Int64.Type},{"Remaining",Int64.Type},{"UnitPrice",Int64.Type},{"Index",Int64.Type}}, "en-US"),
 Zeros = Table.ReplaceValue(Typed, null, 0, Replacer.ReplaceValue, {"Received","Issued"}),
 Sorted = Table.Sort(Zeros, {{"ItemName",Order.Ascending},{"Date",Order.Ascending},{"Index",Order.Ascending}})
 , Jenis = Table.AddColumn(Sorted,"JenisCatatan", each if [Issued] > 0 then "Pengeluaran" else if [Received] > 0 then "Penerimaan" else "Tanpa mutasi",type text),
 Pemakaian = Table.AddColumn(Jenis,"Pemakaian",each [Issued],Int64.Type)
in Pemakaian
