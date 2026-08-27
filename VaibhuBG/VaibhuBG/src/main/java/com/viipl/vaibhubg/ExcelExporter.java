package com.viipl.vaibhubg;

import java.io.ByteArrayOutputStream;
import java.util.List;

import org.apache.poi.hssf.usermodel.HSSFWorkbook; // <-- Uses basic HSSF
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.DataFormat;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;

public class ExcelExporter {

    public static byte[] generateExcel(List<BGPojo> bgList) throws Exception {
        Workbook workbook = new HSSFWorkbook(); // <-- Changed from XSSFWorkbook to HSSFWorkbook
        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        try {
            Sheet sheet = workbook.createSheet("Bank Guarantees");

            // --- Styles Definition ---
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBoldweight(Font.BOLDWEIGHT_BOLD);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.BLUE.getIndex());
            headerStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
            headerStyle.setAlignment(CellStyle.ALIGN_CENTER);
            headerStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);

            CellStyle dateStyle = workbook.createCellStyle();
            DataFormat format = workbook.createDataFormat();
            dateStyle.setDataFormat(format.getFormat("dd-mmm-yyyy"));

            CellStyle amountStyle = workbook.createCellStyle();
            amountStyle.setDataFormat(format.getFormat("#,##,##0.00"));

            CellStyle intStyle = workbook.createCellStyle();
            intStyle.setDataFormat(format.getFormat("#,##0"));

            // --- Header Row ---
            String[] headers = {
                "BG ID", "Department", "BG TYPE","Work Description", "BG Number", 
                "PO Number", "PO Amount", "BG Date", "BG Expiry Date", 
                "BG Period", "Days Remaining"
            };

            Row headerRow = sheet.createRow(0);
            headerRow.setHeight((short) 450);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // --- Data Rows ---
            long today = System.currentTimeMillis();
            int rowIndex = 1;

            for (BGPojo bg : bgList) {
                Row row = sheet.createRow(rowIndex++);

                // 0: BG ID
                Cell c0 = row.createCell(0);
                if (bg.getBgId() != 0) {
                    c0.setCellValue(bg.getBgId());
                }

                // 1: Department
                row.createCell(1).setCellValue(bg.getDepartment() != null ? bg.getDepartment() : "");

                row.createCell(2).setCellValue(bg.getBgType() != null ? bg.getBgType() : "");
                
                // 2: Work Description
                row.createCell(3).setCellValue(bg.getBgWorkdesc() != null ? bg.getBgWorkdesc() : "");

                // 3: BG Number
                row.createCell(4).setCellValue(bg.getBgNumber() != null ? bg.getBgNumber() : "");

                // 4: PO Number
                row.createCell(5).setCellValue(bg.getPoNumber() != null ? bg.getPoNumber() : "");

                // 5: PO Amount
                Cell c5 = row.createCell(6);
                if (bg.getPoAmount() != null) {
                    c5.setCellValue(bg.getPoAmount().doubleValue());
                    c5.setCellStyle(amountStyle);
                }

                // 6: BG Date
                Cell c6 = row.createCell(7);
                if (bg.getBgDate() != null) {
                    c6.setCellValue(bg.getBgDate());
                    c6.setCellStyle(dateStyle);
                }

                // 7: BG Expiry Date
                Cell c7 = row.createCell(8);
                if (bg.getBgExpiryDate() != null) {
                    c7.setCellValue(bg.getBgExpiryDate());
                    c7.setCellStyle(dateStyle);
                }

                // 8: BG Period
                row.createCell(9).setCellValue(bg.getBgPeriod() != null ? bg.getBgPeriod() : "");

                // 9: Days Remaining
                Cell c9 = row.createCell(10);
                if (bg.getBgExpiryDate() != null) {
                    long daysRemaining = (bg.getBgExpiryDate().getTime() - today) / (1000 * 60 * 60 * 24);
                    c9.setCellValue(daysRemaining);
                    c9.setCellStyle(intStyle);
                }
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
                sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
            }

            workbook.write(baos);
            return baos.toByteArray();

        } finally {
            baos.close();
        }
    }
}