package com.vaibhutrans.model;

import java.sql.Date;

public class Transaction {
    private String utrNo;
    private Date transactionDate;
    private String debitAccount;
    private String benfAccount;
    private double amount;
    private String paymentMode;
    private String status;
    private String narration;    // Formerly 'remark'
    private String tallyledger;   // New field
    private String project;       // New field

    // Joined fields from bank_details
    private String benfName;
    private String benfIfsc;
    private String benfBranch;
    private String benfBank;

    public Transaction() {}

    public Transaction(String utrNo, Date transactionDate, String debitAccount, String benfAccount, 
                       double amount, String paymentMode, String status, String narration, 
                       String tallyledger, String project) {
        this.utrNo = utrNo;
        this.transactionDate = transactionDate;
        this.debitAccount = debitAccount;
        this.benfAccount = benfAccount;
        this.amount = amount;
        this.paymentMode = paymentMode;
        this.status = status;
        this.narration = narration;
        this.tallyledger = tallyledger;
        this.project = project;
    }

    // Getters and Setters
    public String getUtrNo() { return utrNo; }
    public void setUtrNo(String utrNo) { this.utrNo = utrNo; }

    public Date getTransactionDate() { return transactionDate; }
    public void setTransactionDate(Date transactionDate) { this.transactionDate = transactionDate; }

    public String getDebitAccount() { return debitAccount; }
    public void setDebitAccount(String debitAccount) { this.debitAccount = debitAccount; }

    public String getBenfAccount() { return benfAccount; }
    public void setBenfAccount(String benfAccount) { this.benfAccount = benfAccount; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

    public String getPaymentMode() { return paymentMode; }
    public void setPaymentMode(String paymentMode) { this.paymentMode = paymentMode; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNarration() { return narration; }
    public void setNarration(String narration) { this.narration = narration; }

    public String getTallyledger() { return tallyledger; }
    public void setTallyledger(String tallyledger) { this.tallyledger = tallyledger; }

    public String getProject() { return project; }
    public void setProject(String project) { this.project = project; }

    public String getBenfName() { return benfName; }
    public void setBenfName(String benfName) { this.benfName = benfName; }

    public String getBenfIfsc() { return benfIfsc; }
    public void setBenfIfsc(String benfIfsc) { this.benfIfsc = benfIfsc; }

    public String getBenfBranch() { return benfBranch; }
    public void setBenfBranch(String benfBranch) { this.benfBranch = benfBranch; }

    public String getBenfBank() { return benfBank; }
    public void setBenfBank(String benfBank) { this.benfBank = benfBank; }
}