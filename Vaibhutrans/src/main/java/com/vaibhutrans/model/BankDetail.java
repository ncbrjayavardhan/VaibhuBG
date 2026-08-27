package com.vaibhutrans.model;

public class BankDetail {
    private String benfAccount;
    private String benfName;
    private String benfIfsc;
    private String benfBranch;
    private String benfBank;

    public BankDetail() {}

    public BankDetail(String benfAccount, String benfName, String benfIfsc, String benfBranch, String benfBank) {
        this.benfAccount = benfAccount;
        this.benfName = benfName;
        this.benfIfsc = benfIfsc;
        this.benfBranch = benfBranch;
        this.benfBank = benfBank;
    }

    public String getBenfAccount() { return benfAccount; }
    public void setBenfAccount(String benfAccount) { this.benfAccount = benfAccount; }

    public String getBenfName() { return benfName; }
    public void setBenfName(String benfName) { this.benfName = benfName; }

    public String getBenfIfsc() { return benfIfsc; }
    public void setBenfIfsc(String benfIfsc) { this.benfIfsc = benfIfsc; }

    public String getBenfBranch() { return benfBranch; }
    public void setBenfBranch(String benfBranch) { this.benfBranch = benfBranch; }

    public String getBenfBank() { return benfBank; }
    public void setBenfBank(String benfBank) { this.benfBank = benfBank; }
}