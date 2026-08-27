# BG Report Export & Print Features

This document explains the export and print functionality added to the BG Report module.

## Features Added

### 1. **Excel Export**
- Export report to CSV format (can be opened with Excel)
- Includes all filtered records (respects current filters)
- Columns: BG ID, Department, Work Description, BG Number, PO Number, PO Amount, BG Date, BG Expiry Date, BG Period, Days Remaining
- File name: `BG_Report.xlsx`

**Implementation:**
- Uses `ExcelExporter.java` to generate CSV data
- No external dependencies required (uses basic CSV format)
- Can be enhanced with Apache POI for true XLSX format with formatting

### 2. **PDF Export**
- Export report to HTML-based PDF
- Includes all filtered records
- Professional formatting with table layout
- Generated with timestamp of report generation
- File name: `BG_Report.pdf`

**Implementation:**
- Uses `PdfExporter.java` to generate HTML report
- No external dependencies required
- Opens in browser with instruction to save as PDF
- User can press Ctrl+P (Cmd+P on Mac) to print/save as PDF

### 3. **Print Functionality**
- Browser-native print capability
- Print-friendly CSS hides filter controls, pagination, and export buttons
- Automatic page breaks for large datasets
- Optimized for A4/Letter paper size

**Implementation:**
- Uses CSS `@media print` rules
- JavaScript `window.print()` trigger
- Classes `no-print` hide non-essential elements during printing

## File Changes

### Java Files
- **BGServlet.java**
  - Added `exportReportToExcel()` method
  - Added `exportReportToPdf()` method
  - Added `fetchReportData()` helper method to fetch filtered data
  - New actions: `exportExcel`, `exportPdf`

- **ExcelExporter.java** (NEW)
  - Generates CSV format export
  - Proper CSV escaping for special characters
  - Date formatting (dd-MMM-yyyy)
  - Days remaining calculation

- **PdfExporter.java** (NEW)
  - Generates HTML table format
  - Professional styling
  - Color-coded status (expired, warning, ok)
  - HTML entity escaping for safe output

### JSP Files
- **bgreport.jsp**
  - Added export buttons: Excel, PDF, Print
  - Added print-friendly CSS
  - Added `no-print` class to filter form and pagination controls

## Usage

### Excel Export
1. Click the **📊 Excel** button in the export section
2. Browser downloads `BG_Report.xlsx`
3. Open with Excel or any spreadsheet application

### PDF Export
1. Click the **📄 PDF** button in the export section
2. Browser opens the report in an HTML viewer
3. Press **Ctrl+P** (or **Cmd+P** on Mac)
4. Select printer as "Save to PDF" or "Print to File"
5. Click Print

### Print
1. Click the **🖨️ Print** button in the export section
2. Browser print dialog opens
3. Select printer and configure print settings
4. Click Print

## Filter Persistence with Export

The export actions respect the current filters applied to the report:
- **Department filter**: Only exports records from selected department
- **PO Number filter**: Only exports records matching PO number search
- **BG Number filter**: Only exports records matching BG number search

To export all records, click "Clear Filters" first.

## Future Enhancements

### Enhanced Excel Export (requires Apache POI)
Add to `pom.xml`:
```xml
<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi-ooxml</artifactId>
    <version>5.2.3</version>
</dependency>
```

Benefits:
- True XLSX format with cell formatting
- Column width auto-fit
- Bold headers
- Number formatting for PO Amount
- Conditional formatting for status colors

### Enhanced PDF Export (requires iText)
Add to `pom.xml`:
```xml
<dependency>
    <groupId>com.itextpdf</groupId>
    <artifactId>itextpdf</artifactId>
    <version>5.5.13</version>
</dependency>
```

Benefits:
- True PDF generation (not HTML-based)
- Advanced layout control
- Image embedding
- Digital signatures
- Form fields

## Testing Checklist

- [ ] Test Excel export with no filters
- [ ] Test Excel export with department filter
- [ ] Test Excel export with PO Number filter
- [ ] Test Excel export with BG Number filter
- [ ] Test PDF export with various filters
- [ ] Test Print functionality (Ctrl+P / Cmd+P)
- [ ] Verify printed output hides filters and pagination
- [ ] Test with large datasets (pagination)
- [ ] Test special characters in data (commas, quotes, etc.)
- [ ] Verify file downloads work correctly
- [ ] Test on multiple browsers (Chrome, Firefox, Safari, Edge)

## Performance Considerations

- Export fetches ALL filtered records (no pagination limit)
- For very large datasets (>10,000 records), consider adding pagination limits
- CSV export is lightweight and fast
- PDF export generates HTML on-the-fly (suitable for reports up to ~5,000 rows)

## Browser Compatibility

- **Excel Export**: Works in all modern browsers
- **PDF Export**: Works in all modern browsers (downloads HTML as PDF)
- **Print**: Works in all modern browsers

## Troubleshooting

### PDF Export opens in browser instead of downloading
- This is by design! The PDF report opens in your browser with instructions.
- Press Ctrl+P (Cmd+P on Mac) and select "Save as PDF" to save it.
- This approach works in all browsers without additional libraries.

### Export button doesn't work
- Check browser console for JavaScript errors
- Verify BGServlet is accessible at `/context/BGServlet`
- Check that export actions are properly mapped in servlet

### Downloaded file is empty or corrupted
- Check server logs for exceptions
- Verify database connection and data availability
- Try with fewer filters first

### Print output looks wrong
- Check print preview in browser (Ctrl+P)
- Adjust page margins in print dialog
- Enable "Background colors" in advanced print settings
- Try Chrome/Firefox for best results
