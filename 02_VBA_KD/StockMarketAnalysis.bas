Attribute VB_Name = "Module11"
Sub ClearOutput()
 
 Dim Sheet As Worksheet
  
 For Each Sheet In Worksheets
   Sheet.Range("I:Q").Clear
 Next
End Sub

Sub ApplyStep1(Sheet As Worksheet)
  ' Step1 - Easy
  ' This routine will loop through each year of stock data and grab the total amount of volume each stock had over the year
  ' Will also display the ticker symbol to coincide with the total volume
  ' Note: This algorithm assumes that input data is sorted by ticker symbol
  Dim TotalVol As Double
  Dim LastRow, OutRow As Integer
  
  
  ' Clear Output Columns
  Sheet.Range("I:J").Clear
  
  ' Insert Headers for Output Columns
  Sheet.Range("I1").Value = "Ticker"
  Sheet.Range("J1").Value = "Total Stock Volume"
  
  OutRow = 2 ' Output Starts at Row 2
  TotalVol = 0 ' Initialize Total Volume to 0
  LastRow = Sheet.Cells(Sheet.Rows.Count, 1).End(xlUp).Row ' Detect Last Row
  For CurrRow = 2 To LastRow
    Dim Vol As Double
    Dim CurrSymbol, NextSymbol As String
    CurrSymbol = Sheet.Range("A" & CurrRow).Value
    NextSymbol = Sheet.Range("A" & CurrRow + 1).Value
    Vol = Sheet.Range("G" & CurrRow).Value
    
    TotalVol = TotalVol + Vol
    If CurrSymbol <> NextSymbol Then
      Sheet.Range("I" & OutRow).Value = CurrSymbol
      Sheet.Range("J" & OutRow).Value = TotalVol
      TotalVol = 0 ' Reset Total Volume Counter
      OutRow = OutRow + 1 ' Increment Output Row Index
    End If
  Next CurrRow
  
  Sheet.Columns.AutoFit ' Adjust the column width to fit the column content
  
End Sub

Sub ApplyStep1OnCurrent()
  ' This routine applies step #1 on the current sheet
    
  Call ApplyStep1(ActiveSheet)
End Sub

Sub ApplyStep1OnAllSheets()
  ' This routine applies step #1 on the all sheets
  Dim Sheet As Worksheet
  
  For Each Sheet In Worksheets
    Call ApplyStep1(Sheet)
  Next
End Sub

Sub ApplyStep2(Sheet As Worksheet)
  ' Step3 - Hard
  ' This routine will loop through all the stocks and take the following info
  '    - Yearly change from what the stock opened the year at to what the closing price was
  '    - The percent change from the what it opened the year at to what it closed
  '    - The total Volume of the stock
  '    - Ticker symbol
  ' Will also conditionally format that will highlight positive change in green and negative change in red
  ' Note: This algorithm assumes that input data is sorted by ticker symbol and trade date (ascending)
  
  
  ' Clear Output Columns
  Sheet.Range("I:L").Clear
  
  ' Insert Headers for Output Columns
  Sheet.Range("I1").Value = "Ticker"
  Sheet.Range("J1").Value = "Yearly Change"
  Sheet.Range("K1").Value = "Percent Change"
  Sheet.Range("L1").Value = "Total Stock Volume"
  
  Dim TotalVol As Double
  Dim LastRow, OutRow As Integer
  Dim YearlyOpen As Double
  OutRow = 2 ' Output Starts at Row 2
  TotalVol = 0 ' Initialize Total Volume to 0
  LastRow = Sheet.Cells(Sheet.Rows.Count, 1).End(xlUp).Row ' Detect Last Row
  YearlyOpen = Sheet.Range("C2").Value ' Set Yearly Open for Next Symbol to process
  For CurrRow = 2 To LastRow
    Dim Vol, YearlyClose, YearlyChange, YearlyPercentChange As Double
    Dim CurrSymbol, NextSymbol, YearlyPercentChangeStr As String
    
    CurrSymbol = Sheet.Range("A" & CurrRow).Value
    NextSymbol = Sheet.Range("A" & CurrRow + 1).Value
    Vol = Sheet.Range("G" & CurrRow).Value
    
    TotalVol = TotalVol + Vol
    If CurrSymbol <> NextSymbol Then
      YearlyClose = Sheet.Range("F" & CurrRow).Value
      YearlyChange = YearlyClose - YearlyOpen
      If YearlyOpen <> 0 Then
        YearlyPercentChange = YearlyChange / YearlyOpen
        YearlyPercentChangeStr = Str(YearlyPercentChange)
      Else
        YearlyPercentChangeStr = "N/A" ' If Yearly Open is Zero, percentage change cannot be calculated. Display 'N/A' in such case.
      End If
      
      Sheet.Range("I" & OutRow).Value = CurrSymbol
      Sheet.Range("J" & OutRow).Value = YearlyChange
      Sheet.Range("J" & OutRow).NumberFormat = "0.000000000"
      If YearlyChange < 0 Then
        Sheet.Range("J" & OutRow).Interior.Color = vbRed
      Else
        Sheet.Range("J" & OutRow).Interior.Color = vbGreen
      End If
      Sheet.Range("K" & OutRow).Value = YearlyPercentChangeStr
      Sheet.Range("K" & OutRow).NumberFormat = "0.00%"
      Sheet.Range("L" & OutRow).Value = TotalVol
      
      YearlyOpen = Sheet.Range("C" & CurrRow + 1).Value ' Set Yearly Open for Next Symbol to process
      TotalVol = 0 ' Reset Total Volume Counter
      OutRow = OutRow + 1 ' Increment Output Row Index
    End If
  Next CurrRow
  
  Sheet.Columns.AutoFit ' Adjust the column width to fit the column content
  
End Sub



Sub ApplyStep2OnCurrent()
  ' This routine applies step #2 on the current sheet
    
  Call ApplyStep2(ActiveSheet)
End Sub

Sub ApplyStep2OnAllSheets()
  ' This routine applies step #2 on the all sheets
  Dim Sheet As Worksheet
  
  For Each Sheet In Worksheets
    Call ApplyStep2(Sheet)
  Next
End Sub

Sub ApplyStep3(Sheet As Worksheet)
  ' Step2 - Moderate
  ' This routine will loop through all the stocks and take the following info
  '    - Yearly change from what the stock opened the year at to what the closing price was
  '    - The percent change from the what it opened the year at to what it closed
  '    - The total Volume of the stock
  '    - Ticker symbol
  ' Will also conditionally format that will highlight positive change in green and negative change in red
  ' Will also locate the stock with the "Greatest % increase", "Greatest % Decrease" and "Greatest total volume"
  ' Note: This algorithm assumes that input data is sorted by ticker symbol and trade date (ascending)
  
  
  ' Clear Output Columns
  Sheet.Range("I:Q").Clear
  
  ' Insert Headers for Output Columns
  Sheet.Range("I1").Value = "Ticker"
  Sheet.Range("J1").Value = "Yearly Change"
  Sheet.Range("K1").Value = "Percent Change"
  Sheet.Range("L1").Value = "Total Stock Volume"
  Sheet.Range("P1").Value = "Ticker"
  Sheet.Range("Q1").Value = "Value"
  Sheet.Range("O2").Value = "Greatest % Increase"
  Sheet.Range("O3").Value = "Greatest % Decrease"
  Sheet.Range("O4").Value = "Greatest Total Volume"
  
  Dim TotalVol As Double
  Dim LastRow, OutRow As Integer
  Dim YearlyOpen As Double
  Dim GYISymbol, GYDSymbol, GYVSymbol As String
  Dim GYIValue, GYDValue, GYVValue As Double
  
  OutRow = 2 ' Output Starts at Row 2
  TotalVol = 0 ' Initialize Total Volume to 0
  LastRow = Sheet.Cells(Sheet.Rows.Count, 1).End(xlUp).Row ' Detect Last Row
  YearlyOpen = Sheet.Range("C2").Value ' Set Yearly Open for Next Symbol to process
  
  GYIValue = 0 ' Initialize Greatest % Increase to 0
  GYDValue = 0 ' Initialize Greatest % Decrease to 0
  GYVValue = 0 ' Initialize Greatest Total Volume to 0
  
  For CurrRow = 2 To LastRow
    Dim Vol, YearlyClose, YearlyChange, YearlyPercentChange As Double
    Dim CurrSymbol, NextSymbol, YearlyPercentChangeStr As String
    
    CurrSymbol = Sheet.Range("A" & CurrRow).Value
    NextSymbol = Sheet.Range("A" & CurrRow + 1).Value
    Vol = Sheet.Range("G" & CurrRow).Value
    
    TotalVol = TotalVol + Vol
    If CurrSymbol <> NextSymbol Then
      YearlyClose = Sheet.Range("F" & CurrRow).Value
      YearlyChange = YearlyClose - YearlyOpen
      If YearlyOpen <> 0 Then
        YearlyPercentChange = YearlyChange / YearlyOpen
        YearlyPercentChangeStr = Str(YearlyPercentChange)
        If YearlyPercentChange > GYIValue Then
            GYIValue = YearlyPercentChange
            GYISymbol = CurrSymbol
        End If
        
        If YearlyPercentChange < GYDValue Then
            GYDValue = YearlyPercentChange
            GYDSymbol = CurrSymbol
        End If
      Else
        YearlyPercentChangeStr = "N/A" ' If Yearly Open is Zero, percentage change cannot be calculated. Display 'N/A' in such case.
      End If
      
      If TotalVol > GYVValue Then
            GYVValue = TotalVol
            GYVSymbol = CurrSymbol
      End If
      
      Sheet.Range("I" & OutRow).Value = CurrSymbol
      Sheet.Range("J" & OutRow).Value = YearlyChange
      Sheet.Range("J" & OutRow).NumberFormat = "0.000000000"
      If YearlyChange < 0 Then
        Sheet.Range("J" & OutRow).Interior.Color = vbRed
      Else
        Sheet.Range("J" & OutRow).Interior.Color = vbGreen
      End If
      Sheet.Range("K" & OutRow).Value = YearlyPercentChangeStr
      Sheet.Range("K" & OutRow).NumberFormat = "0.00%"
      Sheet.Range("L" & OutRow).Value = TotalVol
      
      YearlyOpen = Sheet.Range("C" & CurrRow + 1).Value ' Set Yearly Open for Next Symbol to process
      TotalVol = 0 ' Reset Total Volume Counter
      OutRow = OutRow + 1 ' Increment Output Row Index
    End If
  Next CurrRow
  Sheet.Range("P2").Value = GYISymbol
  Sheet.Range("P3").Value = GYDSymbol
  Sheet.Range("P4").Value = GYVSymbol
  Sheet.Range("Q2").Value = GYIValue
  Sheet.Range("Q2").NumberFormat = "0.00%"
  Sheet.Range("Q3").Value = GYDValue
  Sheet.Range("Q3").NumberFormat = "0.00%"
  Sheet.Range("Q4").Value = GYVValue
  
  Sheet.Columns.AutoFit ' Adjust the column width to fit the column content
  
End Sub


Sub ApplyStep3OnCurrent()
  ' This routine applies step #3 on the current sheet
    
  Call ApplyStep3(ActiveSheet)
End Sub

Sub ApplyStep3OnAllSheets()
  ' This routine applies step #3 on the all sheets
  Dim Sheet As Worksheet
  
  For Each Sheet In Worksheets
    Call ApplyStep3(Sheet)
  Next
End Sub
