package com.vaibhutrans;


import java.sql.Connection;
import java.sql.DriverManager;

public class TestConnection {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		try {
            Class.forName("org.postgresql.Driver");

            Connection con = DriverManager.getConnection(
                    "jdbc:postgresql://jay.spoorthy.net:5432/vaibhu_db",
                    "jay",
                    "jay@123");

            System.out.println("Connected Successfully!");

            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
	}

}
