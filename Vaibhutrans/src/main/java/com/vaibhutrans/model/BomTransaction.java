package com.vaibhutrans.model;

public class BomTransaction {
    private String txDate;
    private String type;
    private String particulars;
    private String utrNo;
    private String beneficiaryName;
    private String ifscCode;
    private String refNo;
    private double debit;
    private double credit;
    private double balance;
    private String channel;
    private String bankName;
    private String accountNo;
    private String tallyLedger;
    private String narration;

    public BomTransaction() {}

    public String getTxDate() { return txDate; }
    public void setTxDate(String txDate) { this.txDate = txDate; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getParticulars() { return particulars; }
    public void setParticulars(String particulars) { this.particulars = particulars; }

    public String getUtrNo() { return utrNo; }
    public void setUtrNo(String utrNo) { this.utrNo = utrNo; }

    public String getBeneficiaryName() { return beneficiaryName; }
    public void setBeneficiaryName(String beneficiaryName) { this.beneficiaryName = beneficiaryName; }

    public String getIfscCode() { return ifscCode; }
    public void setIfscCode(String ifscCode) { this.ifscCode = ifscCode; }

    public String getRefNo() { return refNo; }
    public void setRefNo(String refNo) { this.refNo = refNo; }

    public double getDebit() { return debit; }
    public void setDebit(double debit) { this.debit = debit; }

    public double getCredit() { return credit; }
    public void setCredit(double credit) { this.credit = credit; }

    public double getBalance() { return balance; }
    public void setBalance(double balance) { this.balance = balance; }

    public String getChannel() { return channel; }
    public void setChannel(String channel) { this.channel = channel; }
    
    public String getBankName() { return bankName; }
    public void setBankName(String bankName) { this.bankName = bankName; }

    public String getAccountNo() { return accountNo; }
    public void setAccountNo(String accountNo) { this.accountNo = accountNo; }
    
    public String getTallyLedger() { return tallyLedger; }
    public void setTallyLedger(String tallyLedger) { this.tallyLedger = tallyLedger; }
    
    public String getNarration() { return narration; }
    public void setNarration(String narration) { this.narration = narration; }
    
    
}