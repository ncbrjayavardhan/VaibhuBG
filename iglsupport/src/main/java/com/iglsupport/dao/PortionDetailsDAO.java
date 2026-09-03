package com.iglsupport.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.iglsupport.config.DBConnection;
import com.iglsupport.model.PortionDetailsDTO;

public class PortionDetailsDAO {

    public static List<PortionDetailsDTO> getAllPortionDetails() {
        List<PortionDetailsDTO> list = new ArrayList<>();
        String sql = "SELECT p.pid, p.inv_status, pd.vid, pd.state, pd.city, pd.ga, pd.total_data, pd.start_date, pd.end_date " +
                     "FROM portion p " +
                     "LEFT JOIN portion_details pd ON p.pid = pd.pid " +
                     "ORDER BY pd.state ASC, pd.city ASC, pd.ga ASC, p.pid ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                PortionDetailsDTO dto = new PortionDetailsDTO();
                dto.setPid(rs.getInt("pid"));
                dto.setInvStatus(rs.getInt("inv_status"));
                dto.setVid(rs.getInt("vid"));
                dto.setState(rs.getString("state"));
                dto.setCity(rs.getString("city"));
                dto.setGa(rs.getString("ga"));

                int totalData = rs.getInt("total_data");
                dto.setTotalData(rs.wasNull() ? null : totalData);

                Date sDate = rs.getDate("start_date");
                Date eDate = rs.getDate("end_date");
                dto.setStartDate(sDate != null ? sDate.toLocalDate() : null);
                dto.setEndDate(eDate != null ? eDate.toLocalDate() : null);

                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static boolean saveOrUpdate(PortionDetailsDTO dto) {
        String sql = "INSERT INTO portion_details (vid, state, city, ga, pid, total_data, start_date, end_date) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "vid = VALUES(vid), " +
                     "state = VALUES(state), " +
                     "city = VALUES(city), " +
                     "ga = VALUES(ga), " +
                     "total_data = VALUES(total_data), " +
                     "start_date = VALUES(start_date), " +
                     "end_date = VALUES(end_date)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {

            pst.setInt(1, dto.getVid());
            pst.setString(2, dto.getState());
            pst.setString(3, dto.getCity());
            pst.setString(4, dto.getGa());
            pst.setInt(5, dto.getPid());

            if (dto.getTotalData() != null) {
                pst.setInt(6, dto.getTotalData());
            } else {
                pst.setNull(6, java.sql.Types.INTEGER);
            }

            if (dto.getStartDate() != null) {
                pst.setDate(7, Date.valueOf(dto.getStartDate()));
            } else {
                pst.setNull(7, java.sql.Types.DATE);
            }

            if (dto.getEndDate() != null) {
                pst.setDate(8, Date.valueOf(dto.getEndDate()));
            } else {
                pst.setNull(8, java.sql.Types.DATE);
            }

            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}