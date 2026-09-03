package com.iglsupport.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

import com.iglsupport.config.DBConnection;
import com.iglsupport.model.ReportDTO;

public class ReportDAO {

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd-MM-yyyy");

    public static List<ReportDTO> getDailyReport() {
        List<ReportDTO> reportList = new ArrayList<>();

        String sql = "SELECT " +
                "    pd.state, " +
                "    pd.city, " +
                "    g.name AS ga_name, " +
                "    p.pid AS portion_id, " +
                "    p.inv_status, " +
                "    pd.total_data, " +
                "    pd.start_date, " +
                "    pd.end_date, " +
                "    COALESCE(r_today.cnt, 0) AS today_reading, " +
                "    COALESCE(r_yday_exact.cnt, 0) AS yday_reading, " +
                "    COALESCE(r_yday.cnt, 0) AS till_yday_reading " +
                "FROM portion p " +
                "JOIN ga g ON p.gid = g.gid " +
                "LEFT JOIN portion_details pd ON p.pid = pd.pid " +
                "LEFT JOIN (" +
                "    SELECT r.pid, COUNT(r.id) AS cnt " +
                "    FROM readings r " +
                "    JOIN portion_details d ON r.pid = d.pid " +
                "    WHERE DATE(r.reading_date) = CURRENT_DATE() " +
                "      AND (d.start_date IS NULL OR DATE(r.reading_date) >= d.start_date) " +
                "      AND (d.end_date IS NULL OR DATE(r.reading_date) <= d.end_date) " +
                "    GROUP BY r.pid " +
                ") r_today ON p.pid = r_today.pid " +
                "LEFT JOIN (" +
                "    SELECT r.pid, COUNT(r.id) AS cnt " +
                "    FROM readings r " +
                "    JOIN portion_details d ON r.pid = d.pid " +
                "    WHERE DATE(r.reading_date) = CURRENT_DATE() - INTERVAL 1 DAY " +
                "      AND (d.start_date IS NULL OR DATE(r.reading_date) >= d.start_date) " +
                "      AND (d.end_date IS NULL OR DATE(r.reading_date) <= d.end_date) " +
                "    GROUP BY r.pid " +
                ") r_yday_exact ON p.pid = r_yday_exact.pid " +
                "LEFT JOIN (" +
                "    SELECT r.pid, COUNT(r.id) AS cnt " +
                "    FROM readings r " +
                "    JOIN portion_details d ON r.pid = d.pid " +
                "    WHERE DATE(r.reading_date) < CURRENT_DATE() " +
                "      AND (d.start_date IS NULL OR DATE(r.reading_date) >= d.start_date) " +
                "      AND (d.end_date IS NULL OR DATE(r.reading_date) <= d.end_date) " +
                "    GROUP BY r.pid " +
                ") r_yday ON p.pid = r_yday.pid " +
                "WHERE p.inv_status = 1 " +
                "ORDER BY pd.state ASC, pd.city ASC, g.name ASC, p.pid ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            LocalDate today = LocalDate.now();

            while (rs.next()) {
                ReportDTO row = new ReportDTO();
                String state = rs.getString("state");
                String city = rs.getString("city");
                String gaName = rs.getString("ga_name");
                int pid = rs.getInt("portion_id");
                int invStatus = rs.getInt("inv_status");

                row.setState(state != null ? state : "-");
                row.setCity(city != null ? city : "-");
                row.setGaName(gaName != null ? gaName : "-");
                row.setPortionId(pid);

                int totalDataVal = rs.getInt("total_data");
                Integer totalData = rs.wasNull() ? null : totalDataVal;
                row.setTotalData(totalData);

                Date sDate = rs.getDate("start_date");
                Date eDate = rs.getDate("end_date");
                LocalDate startDate = (sDate != null) ? sDate.toLocalDate() : null;
                LocalDate endDate = (eDate != null) ? eDate.toLocalDate() : null;

                row.setStartDate(startDate);
                row.setEndDate(endDate);

                if (startDate != null && endDate != null) {
                    row.setSchedule(startDate.format(DATE_FORMATTER) + " to " + endDate.format(DATE_FORMATTER));
                } else {
                    row.setSchedule("-");
                }

                int todayRead = rs.getInt("today_reading");
                int ydayRead = rs.getInt("yday_reading");
                int tillYdayRead = rs.getInt("till_yday_reading");

                int[] invCounts = getInvoiceCounts(conn, pid, startDate, endDate);
                int todayInv = invCounts[0];
                int ydayInv = invCounts[1];
                int tillYdayInv = invCounts[2];
                
                System.out.println("Yday Read: " + ydayRead);

                int totalRead = todayRead + tillYdayRead;
                int totalInv = todayInv + tillYdayInv;
                int unbilled = (totalData != null) ? Math.max(0, totalData - totalRead) : 0;
                double billedPercent = (totalData != null && totalData > 0) ? ((double) totalRead / totalData) * 100.0 : 0.0;

                row.setTodayReading(todayRead);
                row.setYesterdayReading(ydayRead);
                row.setTodayInv(todayInv);
                row.setYesterdayInv(ydayInv);
                row.setTillYdayRead(tillYdayRead);
                row.setTillYdayInv(tillYdayInv);
                row.setTotalReading(totalRead);
                row.setTotalInv(totalInv);
                row.setUnbilled(unbilled);
                row.setBilledPercent(Math.round(billedPercent * 100.0) / 100.0);

                if (endDate != null && today.isAfter(endDate)) {
                    row.setStatus("Completed");
                } else if (invStatus == 1 && endDate == null) {
                    row.setStatus("Completed");
                } else {
                    row.setStatus("Running");
                }

                if (totalData != null && startDate != null && endDate != null) {
                    long totalDays = ChronoUnit.DAYS.between(startDate, endDate) + 1;
                    if (totalDays > 0) {
                        int perDayTarget = (int) Math.ceil((double) totalData / totalDays);
                        row.setPerDayTarget(perDayTarget);
                        row.setDiff(perDayTarget - todayRead);
                    }
                }

                reportList.add(row);
                System.out.println("row:" + row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("row:" + reportList);
        return reportList;
    }

    private static int[] getInvoiceCounts(Connection conn, int pid, LocalDate startDate, LocalDate endDate) {
        int[] counts = new int[]{0, 0, 0};
        String targetTable = "invoice_" + pid;

        String checkTableSql = "SELECT COUNT(*) FROM information_schema.tables " +
                               "WHERE table_schema = DATABASE() AND table_name = ?";

        try (PreparedStatement checkPst = conn.prepareStatement(checkTableSql)) {
            checkPst.setString(1, targetTable);
            try (ResultSet checkRs = checkPst.executeQuery()) {
                if (checkRs.next() && checkRs.getInt(1) > 0) {
                    StringBuilder invSql = new StringBuilder();
                    invSql.append("SELECT ")
                          .append("  SUM(CASE WHEN DATE(inv_date) = CURRENT_DATE() THEN 1 ELSE 0 END) AS today_inv, ")
                          .append("  SUM(CASE WHEN DATE(inv_date) = CURRENT_DATE() - INTERVAL 1 DAY THEN 1 ELSE 0 END) AS yday_inv, ")
                          .append("  SUM(CASE WHEN DATE(inv_date) < CURRENT_DATE() THEN 1 ELSE 0 END) AS till_yday_inv ")
                          .append("FROM `").append(targetTable).append("` ")
                          .append("WHERE active = 1 ");

                    if (startDate != null) {
                        invSql.append(" AND DATE(inv_date) >= '").append(Date.valueOf(startDate)).append("' ");
                    }
                    if (endDate != null) {
                        invSql.append(" AND DATE(inv_date) <= '").append(Date.valueOf(endDate)).append("' ");
                    }

                    try (PreparedStatement invPst = conn.prepareStatement(invSql.toString());
                         ResultSet invRs = invPst.executeQuery()) {
                        if (invRs.next()) {
                            counts[0] = invRs.getInt("today_inv");
                            counts[1] = invRs.getInt("yday_inv");
                            counts[2] = invRs.getInt("till_yday_inv");
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error reading " + targetTable + ": " + e.getMessage());
        }
        return counts;
    }
}