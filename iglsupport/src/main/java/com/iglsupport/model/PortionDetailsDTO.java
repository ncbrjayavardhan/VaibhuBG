package com.iglsupport.model;

import java.time.LocalDate;

public class PortionDetailsDTO {
    private int vid;
    private String state;
    private String city;
    private String ga;
    private int pid;
    private int invStatus;
    private Integer totalData;
    private LocalDate startDate;
    private LocalDate endDate;

    public PortionDetailsDTO() {}

    // Constructor for saving/updating from the servlet form
    public PortionDetailsDTO(int vid, String state, String city, String ga, int pid, Integer totalData, LocalDate startDate, LocalDate endDate) {
        this.vid = vid;
        this.state = state;
        this.city = city;
        this.ga = ga;
        this.pid = pid;
        this.totalData = totalData;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    // Full constructor including invStatus (used by DAO when listing)
    public PortionDetailsDTO(int vid, String state, String city, String ga, int pid, int invStatus, Integer totalData, LocalDate startDate, LocalDate endDate) {
        this.vid = vid;
        this.state = state;
        this.city = city;
        this.ga = ga;
        this.pid = pid;
        this.invStatus = invStatus;
        this.totalData = totalData;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    // Getters and Setters
    public int getVid() { return vid; }
    public void setVid(int vid) { this.vid = vid; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getGa() { return ga; }
    public void setGa(String ga) { this.ga = ga; }

    public int getPid() { return pid; }
    public void setPid(int pid) { this.pid = pid; }

    public int getInvStatus() { return invStatus; }
    public void setInvStatus(int invStatus) { this.invStatus = invStatus; }

    public Integer getTotalData() { return totalData; }
    public void setTotalData(Integer totalData) { this.totalData = totalData; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
}