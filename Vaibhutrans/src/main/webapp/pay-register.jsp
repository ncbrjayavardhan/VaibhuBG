<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <title>
        Pay Register
    </title>

    <link
        rel="stylesheet"
        href="css/pay-register.css">

</head>


<body>


<div class="container">


    <h2>
        Pay Register Upload
    </h2>


    <!-- SUCCESS MESSAGE -->

    <%
        Object message =
                request.getAttribute("message");

        if (message != null) {
    %>

        <div class="success">
            <%= message %>
        </div>

    <%
        }
    %>


    <!-- ERROR MESSAGE -->

    <%
        Object error =
                request.getAttribute("error");

        if (error != null) {
    %>

        <div class="error">
            <%= error %>
        </div>

    <%
        }
    %>



    <!-- ============================= -->
    <!-- UPLOAD FORM -->
    <!-- ============================= -->


    <div class="card">

        <h3>
            Upload Excel
        </h3>


        <form
            action="pay-register"
            method="post"
            enctype="multipart/form-data">


            <input
                type="hidden"
                name="action"
                value="upload">


            <!-- CLUSTER -->

            <div class="form-group">

                <label>
                    Cluster
                </label>

                <select
                    name="uploadCluster"
                    required>

                    <option value="">
                        -- Select Cluster --
                    </option>

                    <option value="8">
                        Cluster-8
                    </option>

                    <option value="9">
                        Cluster-9
                    </option>

                    <option value="12">
                        Cluster-12
                    </option>

                    <option value="5">
                        Cluster-5
                    </option>

                </select>

            </div>



            <!-- MONTH -->

            <div class="form-group">

                <label>
                    Month
                </label>

                <select
                    name="uploadMonth"
                    required>

                    <option value="">
                        -- Select Month --
                    </option>

                    <option value="JAN">
                        JAN
                    </option>

                    <option value="FEB">
                        FEB
                    </option>

                    <option value="MAR">
                        MAR
                    </option>

                    <option value="APR">
                        APR
                    </option>

                    <option value="MAY">
                        MAY
                    </option>

                    <option value="JUN">
                        JUN
                    </option>

                    <option value="JUL">
                        JUL
                    </option>

                    <option value="AUG">
                        AUG
                    </option>

                    <option value="SEP">
                        SEP
                    </option>

                    <option value="OCT">
                        OCT
                    </option>

                    <option value="NOV">
                        NOV
                    </option>

                    <option value="DEC">
                        DEC
                    </option>

                </select>

            </div>



            <!-- YEAR -->

            <div class="form-group">

                <label>
                    Year
                </label>

                <select
                    name="uploadYear"
                    required>

                    <option value="">
                        -- Select Year --
                    </option>

                    <%
                        int currentYear =
                                java.time.Year.now()
                                    .getValue();

                        for (
                            int y = currentYear;
                            y >= currentYear - 5;
                            y--
                        ) {
                    %>

                        <option value="<%=y%>">
                            <%=y%>
                        </option>

                    <%
                        }
                    %>

                </select>

            </div>



            <!-- FILE -->

            <div class="form-group">

                <label>
                    Excel File
                </label>

                <input
                    type="file"
                    name="excelFile"
                    accept=".xlsx,.xls"
                    required>

            </div>



            <div class="button-area">

                <button
                    type="submit"
                    class="btn-primary">

                    Load Excel

                </button>

            </div>


        </form>

    </div>



    <!-- ============================= -->
    <!-- FILTER -->
    <!-- ============================= -->


    <div class="card">

        <h3>
            Loaded Records
        </h3>


        <form
            action="pay-register"
            method="get"
            class="filter-form">


            <!-- CLUSTER -->

            <div class="form-group">

                <label>
                    Cluster
                </label>

                <select
                    name="cluster"
                    required>

                    <option
                        value="8"
                        <%=
                            "8".equals(
                                request.getAttribute(
                                    "selectedCluster"
                                )
                            )
                            ? "selected"
                            : ""
                        %>>

                        Cluster-8

                    </option>


                    <option
                        value="9"
                        <%=
                            "9".equals(
                                request.getAttribute(
                                    "selectedCluster"
                                )
                            )
                            ? "selected"
                            : ""
                        %>>

                        Cluster-9

                    </option>


                    <option
                        value="12"
                        <%=
                            "12".equals(
                                request.getAttribute(
                                    "selectedCluster"
                                )
                            )
                            ? "selected"
                            : ""
                        %>>

                        Cluster-12

                    </option>


                    <option
                        value="5"
                        <%=
                            "5".equals(
                                request.getAttribute(
                                    "selectedCluster"
                                )
                            )
                            ? "selected"
                            : ""
                        %>>

                        Cluster-5

                    </option>

                </select>

            </div>



            <!-- MONTH -->

            <div class="form-group">

                <label>
                    Month
                </label>

                <select
                    name="month">

                    <option value="">
                        All Months
                    </option>


                    <%
                        String selectedMonth =
                            String.valueOf(
                                request.getAttribute(
                                    "selectedMonth"
                                )
                            );

                        String[] months = {
                            "JAN",
                            "FEB",
                            "MAR",
                            "APR",
                            "MAY",
                            "JUN",
                            "JUL",
                            "AUG",
                            "SEP",
                            "OCT",
                            "NOV",
                            "DEC"
                        };


                        for (
                            String m : months
                        ) {

                            boolean selected =
                                m.equalsIgnoreCase(
                                    selectedMonth
                                );
                    %>

                        <option
                            value="<%=m%>"
                            <%=selected
                                ? "selected"
                                : ""%>>

                            <%=m%>

                        </option>

                    <%
                        }
                    %>

                </select>

            </div>



            <!-- YEAR -->

            <div class="form-group">

                <label>
                    Year
                </label>

                <select
                    name="year">

                    <option value="">
                        All Years
                    </option>


                    <%
                        String selectedYear =
                            String.valueOf(
                                request.getAttribute(
                                    "selectedYear"
                                )
                            );


                        for (
                            int y = currentYear;
                            y >= currentYear - 5;
                            y--
                        ) {

                            boolean selected =
                                String.valueOf(y)
                                    .equals(
                                        selectedYear
                                    );
                    %>

                        <option
                            value="<%=y%>"
                            <%=selected
                                ? "selected"
                                : ""%>>

                            <%=y%>

                        </option>

                    <%
                        }
                    %>

                </select>

            </div>



            <div class="form-group filter-button">

                <button
                    type="submit"
                    class="btn-primary">

                    Filter

                </button>

            </div>


        </form>

    </div>



    <!-- ============================= -->
    <!-- RECORD COUNT -->
    <!-- ============================= -->


    <%
        List<Map<String, Object>> records =
            (List<Map<String, Object>>)
                request.getAttribute(
                    "records"
                );

        if (records == null) {
            records =
                new java.util.ArrayList<>();
        }
    %>


    <div class="record-count">

        Total Records:
        <strong>
            <%=records.size()%>
        </strong>

    </div>



    <!-- ============================= -->
    <!-- DATA TABLE -->
    <!-- ============================= -->


    <div class="table-container">

        <table>

            <thead>

                <tr>

                    <%
                        if (!records.isEmpty()) {

                            Map<String, Object>
                                firstRecord =
                                    records.get(0);

                            for (
                                String column :
                                    firstRecord.keySet()
                            ) {
                    %>

                        <th>

                            <%=column
                                .replace(
                                    "_",
                                    " "
                                )%>

                        </th>

                    <%
                            }
                        }
                    %>

                </tr>

            </thead>



            <tbody>

                <%
                    for (
                        Map<String, Object> record :
                            records
                    ) {
                %>

                    <tr>

                        <%
                            for (
                                Object value :
                                    record.values()
                            ) {
                        %>

                            <td>

                                <%
                                    if (value != null) {
                                %>

                                    <%=value%>

                                <%
                                    }
                                %>

                            </td>

                        <%
                            }
                        %>

                    </tr>

                <%
                    }
                %>

            </tbody>

        </table>

    </div>


</div>


</body>

</html>