package com.viipl.vaibhubg;

import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;
import java.util.List;

/**
 * PDF export utility - generates an HTML report that can be printed to PDF.
 * Browser opens the report as HTML, user can then:
 * 1. Use browser Print (Ctrl+P / Cmd+P) and select "Save as PDF"
 * 2. Or use "Export to PDF" in browser menu
 *
 * For direct PDF generation without browser interaction, integrate iText library:
 *   <dependency>
 *     <groupId>com.itextpdf</groupId>
 *     <artifactId>itextpdf</artifactId>
 *     <version>5.5.13</version>
 *   </dependency>
 */
public class PdfExporter {
    
    public static byte[] generatePdf(List<BGPojo> bgList) throws Exception {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html>\n<html>\n<head>\n");
        html.append("<meta charset=\"UTF-8\"/>\n");
        html.append("<title>BG Report</title>\n");
        html.append("<style>\n");
        html.append("body { font-family: Arial, sans-serif; padding: 20px; }\n");
        html.append("table { width:100%; border-collapse:collapse; margin-top:20px; }\n");
        html.append("thead th { background:#2f6fdb; color:#fff; padding:12px; text-align:left; border:1px solid #ddd; }\n");
        html.append("tbody td { padding:10px; border:1px solid #ddd; }\n");
        html.append("tbody tr:nth-child(even) { background:#f5f5f5; }\n");
        html.append(".expired { color:#c0392b; font-weight:bold; }\n");
        html.append(".warning { color:#e67e22; font-weight:bold; }\n");
        html.append(".ok { color:#27ae60; }\n");
        html.append("@media print { body { margin:0; padding:10px; } }\n");
        html.append("</style>\n");
        html.append("</head>\n<body>\n");
        
        html.append("<h1>BG Report</h1>\n");
        html.append("<p>Report Generated on: ").append(new SimpleDateFormat("dd-MMM-yyyy HH:mm:ss").format(new java.util.Date())).append("</p>\n");
        html.append("<p style=\"color:#666; font-size:12px; border:1px solid #ddd; padding:8px; background:#f9f9f9; margin-bottom:16px;\">\n");
        html.append("💡 <strong>To save as PDF:</strong> Press Ctrl+P (or Cmd+P on Mac) and select \"Save as PDF\" from the print options.\n");
        html.append("</p>\n");
        
        if (bgList == null || bgList.isEmpty()) {
            html.append("<p>No records found.</p>\n");
        } else {
            html.append("<table>\n<thead>\n<tr>\n");
            html.append("<th>BG ID</th>\n");
            html.append("<th>Department</th>\n");
            html.append("<th>Work Desc</th>\n");
            html.append("<th>BG Number</th>\n");
            html.append("<th>PO Number</th>\n");
            html.append("<th>PO Amount</th>\n");
            html.append("<th>BG Date</th>\n");
            html.append("<th>BG Expiry Date</th>\n");
            html.append("<th>BG Period</th>\n");
            html.append("<th>Days Remaining</th>\n");
            html.append("</tr>\n</thead>\n<tbody>\n");
            
            SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy");
            long today = System.currentTimeMillis();
            
            for (BGPojo bg : bgList) {
                html.append("<tr>\n");
                html.append("<td>").append(escapeHtml(String.valueOf(bg.getBgId()))).append("</td>\n");
                html.append("<td>").append(escapeHtml(bg.getDepartment())).append("</td>\n");
                html.append("<td>").append(escapeHtml(bg.getBgWorkdesc())).append("</td>\n");
                html.append("<td>").append(escapeHtml(bg.getBgNumber())).append("</td>\n");
                html.append("<td>").append(escapeHtml(bg.getPoNumber())).append("</td>\n");
                html.append("<td>").append(bg.getPoAmount() != null ? bg.getPoAmount().toPlainString() : "-").append("</td>\n");
                html.append("<td>").append(bg.getBgDate() != null ? sdf.format(bg.getBgDate()) : "N/A").append("</td>\n");
                html.append("<td>").append(bg.getBgExpiryDate() != null ? sdf.format(bg.getBgExpiryDate()) : "N/A").append("</td>\n");
                html.append("<td>").append(escapeHtml(bg.getBgPeriod())).append("</td>\n");
                
                // Days remaining
                html.append("<td>");
                if (bg.getBgExpiryDate() != null) {
                    long daysRemaining = (bg.getBgExpiryDate().getTime() - today) / 86400000;
                    if (daysRemaining < 0) {
                        html.append("<span class=\"expired\">Expired</span>");
                    } else if (daysRemaining <= 30) {
                        html.append("<span class=\"warning\">").append(daysRemaining).append(" days</span>");
                    } else {
                        html.append("<span class=\"ok\">").append(daysRemaining).append(" days</span>");
                    }
                } else {
                    html.append("N/A");
                }
                html.append("</td>\n");
                html.append("</tr>\n");
            }
            
            html.append("</tbody>\n</table>\n");
        }
        
        html.append("</body>\n</html>\n");
        
        byte[] data = html.toString().getBytes("UTF-8");
        baos.write(data);
        baos.flush();
        return baos.toByteArray();
    }
    
    private static String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#39;");
    }
}
