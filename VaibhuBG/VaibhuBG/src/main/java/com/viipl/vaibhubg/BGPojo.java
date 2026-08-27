package com.viipl.vaibhubg;

import java.io.Serializable;
import java.time.LocalDate;

public class BGPojo {
    private long bgId;
    private String department;
    private String bgNumber;
    private java.util.Date bgDate;
    private java.util.Date bgExpiryDate;
    private String bgPeriod;
    private String poNumber;
    private java.math.BigDecimal poAmount;
    private String bgWorkdesc;
    private String bgType;


    public BGPojo(long bgId, String department, String bgNumber, java.util.Date bgDate, java.util.Date bgExpiryDate, String bgPeriod, String poNumber, java.math.BigDecimal poAmount, String bgWorkdesc, String bgType) {
        this.bgId = bgId;
        this.department = department;
        this.bgNumber = bgNumber;
        this.bgDate = bgDate;
        this.bgExpiryDate = bgExpiryDate;
        this.bgPeriod = bgPeriod;
        this.poNumber = poNumber;
        this.poAmount = poAmount;
        this.bgWorkdesc = bgWorkdesc;
        this.bgType = bgType;
    }

    public long getBgId() {
        return bgId;
    }

    public void setBgId(long bgId) {
        this.bgId = bgId;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getBgNumber() {
        return bgNumber;
    }

    public void setBgNumber(String bgNumber) {
        this.bgNumber = bgNumber;
    }

    public java.util.Date getBgDate() {
        return bgDate;
    }

    public void setBgDate(java.util.Date bgDate) {
        this.bgDate = bgDate;
    }

    public java.util.Date getBgExpiryDate() {
        return bgExpiryDate;
    }

    public void setBgExpiryDate(java.util.Date bgExpiryDate) {
        this.bgExpiryDate = bgExpiryDate;
    }

    public String getBgPeriod() {
        return bgPeriod;
    }

    public void setBgPeriod(String bgPeriod) {
        this.bgPeriod = bgPeriod;
    }

    public String getPoNumber() {
        return poNumber;
    }

    public void setPoNumber(String poNumber) {
        this.poNumber = poNumber;
    }

    public java.math.BigDecimal getPoAmount() {
        return poAmount;
    }

    public void setPoAmount(java.math.BigDecimal poAmount) {
        this.poAmount = poAmount;
    }

    public String getBgWorkdesc() {
        return bgWorkdesc;
    }

    public void setBgWorkdesc(String bgWorkdesc) {
        this.bgWorkdesc = bgWorkdesc;
    }

    public String getBgType() {
        return bgType;
    }

    public void setBgType(String bgType) {
        this.bgType = bgType;
    }

    
}
