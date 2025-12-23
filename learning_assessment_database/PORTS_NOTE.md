# Port usage note (learning_assessment_database)

- PostgreSQL must run on **port 5001** (per `db_connection.txt`).
- Avoid running the Node `db_visualizer` server on port 5001 (it will conflict with PostgreSQL binding).
- Recommended:
  - PostgreSQL: 5001
  - db_visualizer (node): 3000 (default in `server.js`) or any other free port

If PostgreSQL reports "Address already in use" for 5001, check what's listening:
- `ss -ltnp | grep ':5001'`
and stop the conflicting process before starting Postgres on 5001.
