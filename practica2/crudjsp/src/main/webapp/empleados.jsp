<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String dbPath = application.getRealPath("/") + "WEB-INF/empresa.db";
    String url = "jdbc:sqlite:" + dbPath;

    Connection conexion = null;
    Statement st = null;
    ResultSet rs = null;

    try {
        Class.forName("org.sqlite.JDBC");
        conexion = DriverManager.getConnection(url);
        st = conexion.createStatement();

        String crearTabla = "CREATE TABLE IF NOT EXISTS empleados ("
                          + "clave INTEGER PRIMARY KEY AUTOINCREMENT, "
                          + "nombre TEXT NOT NULL, "
                          + "direccion TEXT NOT NULL, "
                          + "telefono TEXT NOT NULL)";
        st.executeUpdate(crearTabla);

        String accion = request.getParameter("accion");
        if (accion != null) {
            String nombre = request.getParameter("nombre");
            String direccion = request.getParameter("direccion");
            String telefono = request.getParameter("telefono");
            String clave = request.getParameter("clave");

            if ("crear".equals(accion)) {
                st.executeUpdate("INSERT INTO empleados (nombre,direccion,telefono) VALUES ('"
                        + nombre + "','" + direccion + "','" + telefono + "')");
            } else if ("actualizar".equals(accion)) {
                st.executeUpdate("UPDATE empleados SET nombre='" + nombre
                        + "', direccion='" + direccion + "', telefono='" + telefono
                        + "' WHERE clave=" + clave);
            } else if ("eliminar".equals(accion)) {
                st.executeUpdate("DELETE FROM empleados WHERE clave=" + clave);
            }
        }

        rs = st.executeQuery("SELECT * FROM empleados");

    } catch (Exception e) {
        out.println("<p style='color:red'>Error: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>CRUD Empleados</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: #f0f2f5;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 900px;
            margin: 40px auto;
            padding: 20px;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            color: #333;
        }
        form {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            margin-bottom: 30px;
        }
        .form-group {
            flex: 1 1 30%;
            margin-bottom: 15px;
            display: flex;
            flex-direction: column;
        }
        .form-group label {
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        .form-group input {
            padding: 8px 10px;
            border-radius: 6px;
            border: 1px solid #ccc;
            font-size: 14px;
        }
        .btn {
            padding: 10px 20px;
            background: #4CAF50;
            color: #fff;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            margin-top: 24px;
            flex: 1 1 100%;
            font-size: 16px;
        }
        .employees {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
        }
        .card {
            background: #fafafa;
            border-radius: 10px;
            padding: 20px;
            width: calc(50% - 20px);
            box-shadow: 0 3px 8px rgba(0,0,0,0.05);
        }
        .card h3 {
            margin: 0 0 10px 0;
            color: #333;
        }
        .card p {
            margin: 4px 0;
            color: #555;
        }
        .card .actions {
            margin-top: 10px;
        }
        .card .actions button {
            padding: 6px 12px;
            margin-right: 6px;
            border-radius: 6px;
            border: none;
            cursor: pointer;
            font-size: 14px;
        }
        .edit-btn { background: #2196F3; color: #fff; }
        .delete-btn { background: #f44336; color: #fff; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Gestión de Empleados</h2>

        <form method="POST">
            <input type="hidden" name="accion" id="accion" value="crear">
            <input type="hidden" name="clave" id="clave">
            <div class="form-group">
                <label>Nombre</label>
                <input type="text" name="nombre" id="nombre" required>
            </div>
            <div class="form-group">
                <label>Dirección</label>
                <input type="text" name="direccion" id="direccion" required>
            </div>
            <div class="form-group">
                <label>Teléfono</label>
                <input type="text" name="telefono" id="telefono" required>
            </div>
            <button type="submit" class="btn">Guardar</button>
        </form>

        <div class="employees">
            <%
                try {
                    while(rs != null && rs.next()) {
            %>
            <div class="card">
                <h3><%= rs.getString("nombre") %></h3>
                <p><strong>Dirección:</strong> <%= rs.getString("direccion") %></p>
                <p><strong>Teléfono:</strong> <%= rs.getString("telefono") %></p>
                <div class="actions">
                    <form method="POST" style="display:inline">
                        <input type="hidden" name="accion" value="eliminar">
                        <input type="hidden" name="clave" value="<%= rs.getInt("clave") %>">
                        <button type="submit" class="delete-btn">Eliminar</button>
                    </form>
                    <button class="edit-btn" onclick='editar("<%= rs.getInt("clave") %>","<%= rs.getString("nombre") %>","<%= rs.getString("direccion") %>","<%= rs.getString("telefono") %>")'>Editar</button>
                </div>
            </div>
            <%
                    }
                } catch(Exception e) {
                    out.println("<p style='color:red'>Error cargando empleados: " + e.getMessage() + "</p>");
                } finally {
                    if(rs != null) try { rs.close(); } catch(Exception ignore){}
                    if(st != null) try { st.close(); } catch(Exception ignore){}
                    if(conexion != null) try { conexion.close(); } catch(Exception ignore){}
                }
            %>
        </div>
    </div>

    <script>
    function editar(clave, nombre, direccion, telefono) {
        document.getElementById('clave').value = clave;
        document.getElementById('nombre').value = nombre;
        document.getElementById('direccion').value = direccion;
        document.getElementById('telefono').value = telefono;
        document.getElementById('accion').value = 'actualizar';
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
    </script>
</body>
</html>
