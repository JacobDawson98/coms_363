/**
 * @author Jacob Dawson, dawson
 * @author Chrisitian Eggers, linko
 */
package JDBC;

import java.sql.*;
import java.util.*;

public class P3 {
	public static void main(String[] args) throws Exception {
		// Load and register a JDBC driver
		try {
			// Load the driver (registers itself)
			Class.forName("com.mysql.jdbc.Driver");
		} catch (Exception E) {
			System.err.println("Unable to load driver.");
			E.printStackTrace();
		}
		try {
			// Connect to the database
			Connection conn1;
			String dbUrl = "YOUR URL";
			String user = "YOUR USERNAME";
			String password = "YOUR PASSWORD";
			conn1 = DriverManager.getConnection(dbUrl, user, password);
			System.out.println("*** Connected to the database ***");

			// Create Statement and ResultSet variables to use throughout the project
			Statement statement = conn1.createStatement();
			ResultSet rs;

			/* Part A */
			getAllInstructors(statement);

			/* Part B */
			String meritTableCreate = "CREATE TABLE MeritList" +
				    "(StudentID CHAR(9), " +
				    "Classification CHAR(10), " +
				    "GPA DOUBLE, " +
				    "MentorID CHAR(9), " +
				    "PRIMARY KEY (StudentID));";

			statement.executeUpdate(meritTableCreate);
			System.out.println("Created Table MeritList");

			String top20StudentsQuery = "SELECT StudentID, Classification, MentorID, GPA " +
										 "FROM Student " +
										 "ORDER BY GPA desc;";
			rs = statement.executeQuery(top20StudentsQuery);

			String insertIntoMeritQuery = "INSERT INTO MeritList (StudentID, Classification, GPA, MentorID) VALUES (?, ?, ?, ?);";
			PreparedStatement insertIntoMerit = conn1.prepareStatement(insertIntoMeritQuery);
            int count = 0;
            // Insert the first 20 students
            while (rs.next() && count < 20) {
		    	insertIntoMerit.setString(1, rs.getString("StudentID"));
		    	insertIntoMerit.setString(2, rs.getString("Classification"));
		    	insertIntoMerit.setDouble(3, rs.getDouble("GPA"));
		    	insertIntoMerit.setString(4, rs.getString("MentorID"));
		    	insertIntoMerit.execute();
                ++count;
            }
            // Inserting students that are tied with position 20
            double lastGPA = rs.getDouble("GPA");
            while(rs.next() && count >= 20) {
                if(lastGPA ==  rs.getDouble("GPA")) {
					insertIntoMerit.setString(1, rs.getString("StudentID"));
					insertIntoMerit.setString(2, rs.getString("Classification"));
					insertIntoMerit.setString(3, rs.getString("GPA"));
					insertIntoMerit.setString(4, rs.getString("MentorID"));
					insertIntoMerit.execute();
                } else {
                	break;
                }
                ++count;
            }

            /* Part C */
            String meritListAllQuery = "SELECT * FROM MeritList m ORDER BY m.GPA desc";
            rs = statement.executeQuery(meritListAllQuery);
            while (rs.next()) {
				System.out.println("StudentID: " + rs.getString("StudentID")   + ", MentorID: " + rs.getString("MentorID") + ", GPA: " + rs.getString("GPA")+ ", Classification: "+ rs.getString("Classification"));
            }
            System.out.println();

            /* Part D */
            rs = statement.executeQuery("SELECT * FROM MeritList m ORDER BY m.MentorID desc");
            rs.first();
            String lastMentorID = rs.getString("MentorID");
            String maxClassification = "Freshman";
            HashMap<String, Integer> classificationMap = new HashMap<String, Integer>()
            		{{
            			put("Freshman", 1);
            			put("Sophomore", 2);
            			put("Junior", 3);
            			put("Senior", 4);
            		}};
            double raisePercentage = 1.0;
            while(!rs.isAfterLast()) {
            	while(lastMentorID.equals(rs.getString("MentorID")) && !rs.isLast()) {
            		if(classificationMap.get(maxClassification) < classificationMap.get(rs.getString("Classification"))) {
            			maxClassification = rs.getString("Classification");
            		}
            		rs.next();
            	}
				switch(classificationMap.get(maxClassification)) {
				case 1:
					raisePercentage = 1.04;
					break;
				case 2:
					raisePercentage = 1.06;
					break;
				case 3:
					raisePercentage = 1.08;
					break;
				case 4:
					raisePercentage = 1.1;
					break;
				}

				// Calculate new salary
				String currentInstructorSalaryQ = "SELECT Salary FROM Instructor i where i.InstructorID = " + lastMentorID + ";";
				Statement statement2 = conn1.createStatement();
				ResultSet rs2 = statement2.executeQuery(currentInstructorSalaryQ);
				rs2.first();
				int oldSalary = rs2.getInt("Salary");
				double newSalary = oldSalary * raisePercentage;
				newSalary = Math.round((newSalary * 100)/100.0);

				// Update instructor with new salary
				String updateInstructorQ = "UPDATE Instructor SET Salary = " + newSalary + " WHERE InstructorID = " + lastMentorID + ";";
				statement2.executeUpdate(updateInstructorQ);
				statement2.close();
				rs2.close();

				if(!rs.isAfterLast()) {
					lastMentorID = rs.getString("MentorID");
				}
				maxClassification = rs.getString("Classification");
				rs.next();
            }

            /* Part E */
            getAllInstructors(statement);

			/* Part F */
            statement.executeUpdate("DROP TABLE MeritList;");
            System.out.println("Dropped table MeritList");
			statement.close();
			rs.close();
			conn1.close();
		} catch (SQLException e) {
			System.out.println("SQLException: " + e.getMessage());
			System.out.println("SQLState: " + e.getSQLState());
			System.out.println("VendorError: " + e.getErrorCode());
		}
	}

	/* Helper method for A and E */
	public static void getAllInstructors(Statement statement) {
		try {
			ResultSet rs;
			rs = statement.executeQuery("select Salary, Name, InstructorID from Instructor f, Person p WHERE InstructorID = ID;");
			int totalSalary = 0;
			int salary;

			System.out.println("Faculty Salaries:");
			while (rs.next()) {
				System.out.println(rs.getString("Name") + " " + rs.getString("Salary"));
				salary = rs.getInt("Salary");
				totalSalary += salary;
			}
			System.out.println("Total Salary of all faculty: " + totalSalary + "\n");
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
}
